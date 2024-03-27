import fs from "fs";
import path from "path";
import { test, LaunchTests } from "tst";
import { fileURLToPath } from "url";
const __dirname = path.dirname(fileURLToPath(import.meta.url));

const isProgramLaunchContext = () => {
  return fileURLToPath(import.meta.url) === process.argv[1];
}

isProgramLaunchContext() && LaunchTests(path.resolve(__dirname), {echo_test_logging: true});

export const trivial = test(({t, l}) => {
  t('exemptFromAsserting');
  l('hi')
});

// just doing some controlled inception testing on the main shell script that streamlines this simple github web artifact
// share hosting project.

export const happypath_inception = test(async ({t, l, spawn}) => {
  const sourceDir = '/tmp/static_sharing_test_dir_1';
  fs.mkdirSync(sourceDir, {recursive: true});
  const file = path.resolve(sourceDir, 'test.ts');
  // make a source file, simplest possible html file
  fs.writeFileSync(file, `<body><p>hello world</p></body>`);

  // its def gonna be a bit unkosher since running script will tamper with git status.
  
  await spawn(path.resolve(__dirname, '..', 'publish.sh'), ['-n', 'test', sourceDir]);

  await spawn("rm", ["-rf", sourceDir]);
});

