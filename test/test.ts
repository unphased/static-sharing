import { execSync } from "child_process";
import fs from "fs";
import path from "path";
import { test, LaunchTests } from "tst";
import { fileURLToPath } from "url";
const __dirname = path.dirname(fileURLToPath(import.meta.url));

const isProgramLaunchContext = () => {
  return fileURLToPath(import.meta.url) === process.argv[1];
}

isProgramLaunchContext() && LaunchTests(path.resolve(__dirname), {echo_test_logging: true});

// just doing some controlled inception testing on the main shell script that streamlines this simple github web artifact
// share hosting project.

export const happypath_inception = test(async ({t, l, spawn, cleanup, a: {eq, match}}) => {
  const sourceDir = '/tmp/static_sharing_test_dir_1';
  fs.mkdirSync(sourceDir, {recursive: true});
  const file = path.resolve(sourceDir, 'test.html');
  const name = 'test';
  // make a source file, simplest possible html file
  const body = `<body><p>hello world</p></body>`;
  fs.writeFileSync(file, body);
  const date = execSync("date +%Y-%m-%d").toString().trim();
  cleanup(async () => {
    l('Running cleanup to erase these test dirs...');
    l('But first show some contents');
    await spawn("ls", ["-la", path.resolve(__dirname, '..', date)]);
    await spawn("rm", ["-rf", path.resolve(__dirname, '..', date, name)]);
    if (fs.readdirSync(path.resolve(__dirname, '..', date)).length === 0) {
      l('also cleaning up date dir since we see that it is empty (so likely we made it)')
      await spawn("rm", ["-rf", path.resolve(__dirname, '..', date)]);
    }
    await spawn("ls", ["-la", sourceDir]);
    await spawn("rm", ["-rf", sourceDir]);
  });
  
  // script under test
  const ret = await spawn(path.resolve(__dirname, '..', 'publish.sh'), ['-n', name, sourceDir + '/'], {bufferStdout: true, showStdoutWhenBuffering: true});

  match(ret.stdout, RegExp(`changes added for ${date}/${name}`));
  eq(body, fs.readFileSync(path.resolve(__dirname, '..', date, name, 'test.html')).toString());
});

