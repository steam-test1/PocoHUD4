try {
  let execSync = require('child_process').execSync;
  let gitRev = execSync(`git rev-list --count HEAD`).toString('ascii').trim();
  let gitDescribe = execSync(`git describe --tags`).toString('ascii').trim();

  let pkgJson = require('../package.json');
  let fs = require('fs');
  pkgJson.versionDetail = {
    gitRev, gitDescribe
  }
  fs.writeFileSync('package.json', JSON.stringify(pkgJson, null, 2).replace(/\n/g, '\r\n'), 'utf8');
  console.log(execSync(`git add package.json`).toString('ascii').trim());

  let modTxt = JSON.parse(fs.readFileSync('mod.txt', 'utf8'));
  modTxt.version = gitDescribe
  fs.writeFileSync('mod.txt', JSON.stringify(modTxt, null, 2).replace(/\n/g, '\r\n'), 'utf8');
  console.log(execSync(`git add mod.txt`).toString('ascii').trim());

  console.log(execSync(`git commit --amend -m "Bump version ${gitDescribe} (r${gitRev})"`).toString('ascii').trim());
  console.log(execSync(`git tag -a ${gitDescribe} -m HEAD -f`).toString('ascii').trim());

  console.log(' SUCCESS: Updated Version info:', gitRev, gitDescribe);
} catch (e) {
  console.log(` -- Failed: ${e.message}`);
}
