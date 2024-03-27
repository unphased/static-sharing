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

export const happypath_inception = test(async ({t, l, spawn, f, c, a: {eq, match}}) => {
  const sourceDir = '/tmp/static_sharing_test_dir_1';
  fs.mkdirSync(sourceDir, {recursive: true});
  const file = path.resolve(sourceDir, 'test.html');
  // make a source file, simplest possible html file
  fs.writeFileSync(file, `<body><p>hello world</p></body>`);

  // its def gonna be a bit unkosher since running script will tamper with git status.
  
  const ret = await spawn(path.resolve(__dirname, '..', 'publish.sh'), ['-n', 'test', sourceDir], {bufferStdout: true});

  const date = execSync("date +%Y-%m-%d").toString();
  const regex = RegExp(`changes added for ${date}/${sourceDir}`);
  match(ret.stdout, regex);

  c(async () => {
    l('Running cleaning up to erase these test dirs...');
    await spawn("rm", ["-rf", path.resolve(__dirname, '..', date, sourceDir)]);
    await spawn("rm", ["-rf", sourceDir]);
  });
});

