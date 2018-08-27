/* eslint no-console: "off" */

const { createReporter, columnLeft } = require('../reporter');
const { createDownloadPath } = require('./createDownloadPath');
const { downloadGzipFileFromIMDb } = require('./downloadGzipFileFromIMDb');
const { formatProgress } = require('./formatProgress');

const defaults = {
  downloadDir: 'movieDbData',
  filesToDownload: [
    'title.basics.tsv.gz',
    'title.principals.tsv.gz',
    'name.basics.tsv.gz',
  ],
};

const dependencies = {
  createReporter,
  createDownloadPath,
  downloadGzipFileFromIMDb,
};

const getWithProgress = (file, downloadPath) => {
  const reporter = dependencies.createReporter();
  const fileColumn = columnLeft(file, 30);

  const onDownloadProgress = (progress) => { reporter(`${fileColumn}${formatProgress(progress)}`); };

  const onFinish = () => { reporter(`${fileColumn}Done!`); };

  return dependencies.downloadGzipFileFromIMDb(file, downloadPath, onDownloadProgress, onFinish);
};

const downloadData = async () => {
  const downloadPath = dependencies.createDownloadPath(defaults.downloadDir);
  console.log(`Downloading to ${downloadPath}...`);

  const promises = defaults.filesToDownload.map(
    file => getWithProgress(file, downloadPath),
  );

  try {
    await Promise.all(promises);
    console.log('All downloads complete!');
  } catch (error) {
    console.log(error);
  }

  return downloadPath;
};

module.exports = { defaults, dependencies, downloadData };
