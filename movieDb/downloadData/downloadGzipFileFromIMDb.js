const { createGunzip } = require('zlib');
const { pipeline } = require('stream');
const { promisify } = require('util');
const { existsSync, createWriteStream } = require('fs');
const got = require('got');

const promisePipeline = promisify(pipeline);

const dependencies = {
  got,
  existsSync,
  createWriteStream,
};

const downloadGzipFileFromIMDb = (file, downloadPath, onDownloadProgress, onFinish) => {
  const unzippedFile = `${downloadPath}/${file.replace(/\.gz$/, '')}`;

  if (dependencies.existsSync(unzippedFile)) {
    onFinish();
    return Promise.resolve();
  }

  const request = dependencies.got.stream(`https://datasets.imdbws.com/${file}`)
    .on('downloadProgress', onDownloadProgress);

  const output = dependencies.createWriteStream(unzippedFile).on('finish', onFinish);

  return promisePipeline(request, createGunzip(), output);
};

module.exports = { downloadGzipFileFromIMDb, dependencies };
