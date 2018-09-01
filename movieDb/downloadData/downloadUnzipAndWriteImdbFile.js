const { pipeline } = require('stream');
const { promisify } = require('util');
const { createGunzip } = require('zlib');
const got = require('got');
const { existsSync, createWriteStream } = require('fs');

const promisePipeline = promisify(pipeline);

const dependencies = {
  got,
  createGunzip,
  existsSync,
  createWriteStream,
};

const downloadUnzipAndWriteImdbFile = (file, downloadPath, onDownloadProgress, onFinish) => {
  const unzippedFile = `${downloadPath}/${file.replace(/\.gz$/, '')}`;

  if (dependencies.existsSync(unzippedFile)) {
    onFinish();
    return Promise.resolve();
  }

  const download = dependencies.got.stream(`https://datasets.imdbws.com/${file}`)
    .on('downloadProgress', onDownloadProgress);

  const gunzip = dependencies.createGunzip();

  const writer = dependencies.createWriteStream(unzippedFile)
    .on('finish', onFinish);

  return promisePipeline(download, gunzip, writer);
};

module.exports = { downloadUnzipAndWriteImdbFile, dependencies };
