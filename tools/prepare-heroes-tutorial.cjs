const fs=require('node:fs');
const path=require('node:path');
const root=path.resolve(__dirname,'..');
function lua(value) {
    if (value===null) return 'nil';
    if (typeof value==='string') return JSON.stringify(value);
    if (typeof value==='number'||typeof value==='boolean') return String(value);
    if (Array.isArray(value)) return '{'+value.map(lua).join(',')+'}';
    return '{'+Object.entries(value).map(([key,v])=>'['+lua(key)+']='+lua(v)).join(',')+'}';
}
function render() {
    const script=JSON.parse(fs.readFileSync(path.join(root,'design/tutorials/heroes-script.json'),'utf8'));
    const data=JSON.parse(fs.readFileSync(path.join(root,'src/data/heroes-tutorial-data.json'),'utf8'));
    data.presentationBuildings=require('./heroes-presentation.cjs').presentationBuildings(data);
    const scenes=new Set(['overview','archmages','archmages-target','showcase','xp-initial','xp-range-1',
        'xp-range-2','xp-range-3','xp-empty','xp-modifier-4','xp-modifier-5','xp-modifier-paladin',
        'xp-modifier-outside','empty','items','dice','xp-numbers']);
    const ids=new Set();
    for (const step of [...script.steps,...Object.values(script.optional).flat()]) {
        if (ids.has(step.id)||!step.id) throw new Error('Duplicate/missing Heroes step ID');
        ids.add(step.id);
        if (!scenes.has(step.scene)) throw new Error('Unknown Heroes scene: '+step.scene);
        delete step.authorTriggers; // authorship notes never appear in runtime narration
    }
    if (data.xpRange!==1200||data.xpNeeded.length!==10) throw new Error('Invalid Heroes XP constants');
    return '-- Generated from design/tutorials/heroes-script.json and src/data/heroes-tutorial-data.json.\n'+
        'JTG.HeroesScript = '+lua(script)+'\nJTG.HeroesData = '+lua(data)+'\n';
}
function prepare(check=false) {
    const output=path.join(root,'src/generated/heroes-tutorial.lua'),expected=render();
    const current=fs.existsSync(output)?fs.readFileSync(output,'utf8').replace(/\r\n/g,'\n'):'';
    if(current===expected)return;
    if(check)throw new Error('Heroes tutorial data is stale; run node tools/prepare-heroes-tutorial.cjs');
    fs.writeFileSync(output,expected);
}
module.exports={prepare,render};
if(require.main===module){prepare(process.argv.includes('--check'));console.log('Passed: Heroes authored steps and native-data snapshot.');}
