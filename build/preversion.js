try {
  console.log('Step 1');
  let gitRev = require('child_process').execSync(`git rev-list --count HEAD`).toString('ascii').trim();
  console.log('Step 2');
  let gitDescribe = require('child_process').execSync(`git describe --tags`).toString('ascii').trim();
  console.log('Step 3');

  let pkgJson = require('../package.json');
  var fs = require('fs');
  pkgJson.preversion = {
    gitRev, gitDescribe
  }
  fs.writeFileSync('package.json', JSON.stringify(pkgJson,null,2).replace(/\n/g,'\r\n'), 'utf8');
  let gitAdd = require('child_process').execSync(`git add package.json`).toString('ascii').trim();

  let modTxt = JSON.parse(fs.readFileSync('mod.txt', 'utf8'));
  console.log(JSON.stringify(modTxt,null,1))
  if (false) {
    var fs = require('fs');
    pkgJson.preversion = {
      gitRev, gitDescribe
    }
    fs.writeFileSync('package.json', JSON.stringify(pkgJson,null,2).replace(/\n/g,'\r\n'), 'utf8');
    let gitAdd = require('child_process').execSync(`git add package.json`).to
  }

  console.log('Updated JSON:',gitRev, gitDescribe, pkgJson.version, gitAdd);
} catch (e) {
  console.log(` -- Failed: ${e.message}`);
}
