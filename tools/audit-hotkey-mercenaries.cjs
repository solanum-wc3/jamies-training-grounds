// Read ladder-map camp overrides without changing or importing those maps.
const fs = require('node:fs');
const path = require('node:path');
const {Archive, MPQ_OPEN_READ_ONLY} = require('@jamiephan/stormlib');
const folder = process.argv[2];
if (!folder) throw new Error('Supply the local W3Champions map folder');
const requested = ['AutumnLeaves', 'EchoIsles', 'LastRefuge', 'Springtime', 'FadingAutumn'];
const rows = [];
for (const name of requested) {
    const candidates = fs.readdirSync(folder).filter(file => file.includes(name) && /\.w3[mx]$/i.test(file)).sort();
    if (!candidates.length) throw new Error(`Missing ${name} map`);
    const file = candidates[candidates.length - 1];
    const archive = Archive.open(path.join(folder, file), {flags:MPQ_OPEN_READ_ONLY});
    const overrides = [];
    try {
        let bytes;
        try { bytes = archive.readFile('war3map.w3u'); } catch (_) { bytes = null; }
        if (bytes) {
            let offset = 4;
            const i32 = () => { const value = bytes.readInt32LE(offset); offset += 4; return value; };
            const raw = () => { const value = bytes.toString('ascii', offset, offset+4); offset += 4; return value.replace(/\0/g,''); };
            const string = () => { const end = bytes.indexOf(0,offset); if (end < 0) throw new Error('Unterminated object string'); const value = bytes.toString('utf8',offset,end); offset=end+1; return value; };
            for (let group=0; group<2; group++) {
                const count = i32();
                for (let item=0; item<count; item++) {
                    const base = raw(), custom = raw();
                    if (bytes.readInt32LE(0) >= 3) { const metadataCount=i32(); offset += metadataCount*4; }
                    const mods = i32();
                    for (let mod=0; mod<mods; mod++) {
                        const field = raw(), type = i32();
                        const value = type === 3 ? string() : (type === 0 ? i32() : (() => {const n=bytes.readFloatLE(offset);offset+=4;return n;})());
                        raw();
                        if (['nmer','nmr2'].includes(base)) overrides.push({base,custom,field,value});
                    }
                }
            }
        }
        let script='';
        for (const member of ['war3map.j','war3map.lua']) {
            try { script += archive.readFile(member).toString('utf8'); } catch (_) { }
        }
        if (!script) throw new Error(`No readable map script: ${file}`);
        const luaUnits=[...script.matchAll(/BlzCreateUnitWithSkin\(p,\s*FourCC\("(\w{4})"\)/g)].map(match=>match[1]);
        const jassUnits=[...script.matchAll(/CreateUnit\(\s*p\s*,\s*'(\w{4})'/g)].map(match=>match[1]);
        const placedUnits=[...new Set([...luaUnits,...jassUnits])].sort();
        if (!placedUnits.length) throw new Error(`No readable placed-unit declarations: ${file}`);
        const camps=placedUnits.filter(raw => /^nmer$|^nmr[0-9a-f]$/.test(raw));
        rows.push({map:name,file,camps,placedUnits,overrides});
    } finally { archive.close(); }
}
fs.writeFileSync('src/data/hotkey-mercenary-camps.json', JSON.stringify(rows,null,2)+'\n');
console.log(JSON.stringify(rows,null,2));
