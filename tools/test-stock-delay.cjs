const assert=require('node:assert/strict');
const {patchStockDelay}=require('./patch-stock-delay.cjs');
const i=n=>{const b=Buffer.alloc(4);b.writeInt32LE(n);return b;};
const existing=Buffer.concat([i(3),i(1),Buffer.from('hfoo'),i(0),i(1),i(0),i(1),
    Buffer.from('uhpm'),i(0),i(420),Buffer.from('hfoo'),i(0)]);
const patched=patchStockDelay(existing,['hfoo','Ntin'],'usst');
assert(patched.includes(Buffer.concat([Buffer.from('uhpm'),i(0),i(420),Buffer.from('hfoo')])));
assert(patched.includes(Buffer.concat([Buffer.from('usst'),i(0),i(0),Buffer.from('Ntin')])));
assert.equal(patched.readInt32LE(4),2);
assert.deepEqual(patchStockDelay(patched,['hfoo','Ntin'],'usst'),patched,'Stock patch is not idempotent');
const empty=Buffer.concat([i(3),i(0),i(0)]);
assert(patchStockDelay(empty,['bspd'],'isst').includes(Buffer.concat([Buffer.from('isst'),i(0),i(0),Buffer.from('bspd')])));
console.log('Passed: v3 stock-start overrides preserve unrelated modifications and are idempotent.');
