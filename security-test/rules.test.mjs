import {readFileSync} from 'node:fs';
import {test, before, after} from 'node:test';
import {initializeTestEnvironment, assertSucceeds, assertFails} from '@firebase/rules-unit-testing';
import {doc, setDoc, getDoc, updateDoc, collectionGroup, getDocs, serverTimestamp, Timestamp, writeBatch} from 'firebase/firestore';
let env;
const projectId = 'demo-smartvax';
before(async()=> {
  env = await initializeTestEnvironment({projectId,firestore:{host:'127.0.0.1',port:8080,rules:readFileSync('../firestore.smartvax.rules','utf8')}});
  await env.withSecurityRulesDisabled(async context=> {
    const db=context.firestore();
    await setDoc(doc(db,'users/a/guardians/mother'), {id:'mother',name:'Parent',relation:'Mother',mobile:'7893427676',avatar:'🙂',ownerUid:'a',schemaVersion:1});
    await setDoc(doc(db,'users/a/guardians/father'), {id:'father',name:'Parent',relation:'Father',mobile:'',avatar:'🙂',ownerUid:'a',schemaVersion:1});
    await setDoc(doc(db,'users/a/children/child'), {id:'child',name:'Child',dob:Timestamp.fromDate(new Date('2025-01-01')),gender:'male',bloodGroup:'',cardId:'card',avatar:'🙂',motherId:'mother',fatherId:'father',address:'',emergencyContact:'',notes:'',ownerUid:'a',schemaVersion:1});
    await setDoc(doc(db,'users/a/appointments/visit'), {childId:'child',ownerUid:'a'});
    await setDoc(doc(db,'users/a/vaccinationRecords/record'), {id:'record',childId:'child',vaccineId:'bcg',dose:'Single dose',status:'completed',administeredAt:Timestamp.fromDate(new Date('2025-02-01')),plannedFor:null,doctorId:null,hospitalId:null,batchNumber:'',notes:'',seeded:false,ownerUid:'a',schemaVersion:1});
  });
});
after(async()=>env?.cleanup());
const owner=()=>env.authenticatedContext('a',{phone_number:'+917893427676'}).firestore();
const other=()=>env.authenticatedContext('b',{phone_number:'+919123456789'}).firestore();
test('unauthenticated read rejected',()=>assertFails(getDoc(doc(env.unauthenticatedContext().firestore(),'users/a/children/child'))));
test('unauthenticated write rejected',()=>assertFails(setDoc(doc(env.unauthenticatedContext().firestore(),'users/a/children/new'),{})));
test('owner reads child',()=>assertSucceeds(getDoc(doc(owner(),'users/a/children/child'))));
test('owner edits child',()=>assertSucceeds(updateDoc(doc(owner(),'users/a/children/child'),{notes:'Updated',updatedAt:serverTimestamp()})));
test('other user cannot read child',()=>assertFails(getDoc(doc(other(),'users/a/children/child'))));
test('other user cannot modify vaccination',()=>assertFails(updateDoc(doc(other(),'users/a/vaccinationRecords/record'),{notes:'Unauthorized',updatedAt:serverTimestamp()})));
test('other user cannot read appointment',()=>assertFails(getDoc(doc(other(),'users/a/appointments/visit'))));
test('other user cannot edit guardian',()=>assertFails(updateDoc(doc(other(),'users/a/guardians/mother'),{name:'Other',updatedAt:serverTimestamp()})));
test('invalid record status rejected',()=>assertFails(updateDoc(doc(owner(),'users/a/vaccinationRecords/record'),{status:'invalid',updatedAt:serverTimestamp()})));
test('valid record accepted',()=>assertSucceeds(updateDoc(doc(owner(),'users/a/vaccinationRecords/record'),{notes:'Valid edit',updatedAt:serverTimestamp()})));
test('future vaccination rejected',()=>assertFails(updateDoc(doc(owner(),'users/a/vaccinationRecords/record'),{administeredAt:Timestamp.fromDate(new Date('2099-01-01')),updatedAt:serverTimestamp()})));
test('vaccination before birth rejected',()=>assertFails(updateDoc(doc(owner(),'users/a/vaccinationRecords/record'),{administeredAt:Timestamp.fromDate(new Date('2020-01-01')),updatedAt:serverTimestamp()})));
test('metadata cannot bypass ownership',()=>assertFails(setDoc(doc(other(),'users/a/metadata/seed'),{ownerUid:'b',seedStatus:'complete'})));
test('collection group cannot leak account data',()=>assertFails(getDocs(collectionGroup(other(),'children'))));
test('trusted role injection rejected',()=>assertFails(updateDoc(doc(owner(),'users/a/children/child'),{role:'admin',updatedAt:serverTimestamp()})));
test('invalid guardian link rejected',()=>assertFails(updateDoc(doc(owner(),'users/a/children/child'),{motherId:'missing',updatedAt:serverTimestamp()})));

test('complete real Dart sample dataset fits an atomic rules-checked seed',async()=>{
  const uid='seeded';
  const db=env.authenticatedContext(uid,{phone_number:'+917893427676'}).firestore();
  const input=JSON.parse(readFileSync('sample-dataset.json','utf8'));
  function revive(value) {
    if(value && typeof value==='object' && value.__timestamp) return Timestamp.fromDate(new Date(value.__timestamp));
    if(Array.isArray(value)) return value.map(revive);
    if(value && typeof value==='object') return Object.fromEntries(Object.entries(value).map(([k,v])=>[k,revive(v)]));
    return value;
  }
  const batch=writeBatch(db);
  batch.set(doc(db,`users/${uid}`),{ownerUid:uid,phoneNumber:'+917893427676',schemaVersion:1,createdAt:serverTimestamp(),datasetDate:Timestamp.fromDate(new Date('2026-10-11T06:30:00Z'))});
  for(const [collection,documents] of Object.entries(input)) {
    for(const [id,data] of Object.entries(documents)) {
      batch.set(doc(db,`users/${uid}/${collection}/${id}`),{...revive(data),ownerUid:uid,schemaVersion:1,createdAt:serverTimestamp(),updatedAt:serverTimestamp()});
    }
  }
  batch.set(doc(db,`users/${uid}/metadata/seed`),{ownerUid:uid,seededUid:uid,seedVersion:1,seedStatus:'complete',datasetIdentifier:'smartvax-sharma-v1',schemaVersion:1,completedAt:serverTimestamp(),counts:Object.fromEntries(Object.entries(input).map(([k,v])=>[k,Object.keys(v).length])),skipped:0});
  await assertSucceeds(batch.commit());
  await assertFails(updateDoc(doc(db,`users/${uid}/metadata/seed`),{seedVersion:2}));
});

test('child archival keeps medical references and prevents new record writes',async()=>{
  const uid='seeded'; const db=env.authenticatedContext(uid,{phone_number:'+917893427676'}).firestore();
  await assertSucceeds(updateDoc(doc(db,`users/${uid}/children/child_diya`),{archived:true,updatedAt:serverTimestamp()}));
  const input=JSON.parse(readFileSync('sample-dataset.json','utf8'));
  const id=Object.keys(input.vaccinationRecords).find(key=>input.vaccinationRecords[key].childId==='child_diya');
  await assertSucceeds(getDoc(doc(db,`users/${uid}/vaccinationRecords/${id}`)));
  await assertFails(updateDoc(doc(db,`users/${uid}/vaccinationRecords/${id}`),{notes:'Edit archived child',updatedAt:serverTimestamp()}));
});
