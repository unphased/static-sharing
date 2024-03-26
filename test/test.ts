#!/usr/bin/env -S node --import tsx/esm
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

export const fail = test(({t, l}) => {

});
