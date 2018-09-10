const { pipeline } = require('stream');
const { promisify } = require('util');
const { createGunzip } = require('zlib');
const got = require('got');
const { existsSync, createWriteStream } = require('fs');
const { EventEmitter } = require('events');

const promisePipeline = promisify(pipeline);

const dependencies = {
  got,
  createGunzip,
  existsSync,
  createWriteStream
};

const downloadUnzipAndWriteImdbFile = ({ file, path, emitter }) => {
  const unzippedFile = `${path}/${file.replace(/\.gz$/, '')}`;

  if (dependencies.existsSync(unzippedFile)) {
    emitter.emit('done');
    return Promise.resolve();
  }

  const download = dependencies.got
    .stream(`https://datasets.imdbws.com/${file}`)
    .on('downloadProgress', progress => emitter.emit('progress', progress));

  const gunzip = dependencies.createGunzip();

  const writer = dependencies
    .createWriteStream(unzippedFile)
    .on('finish', () => emitter.emit('done'));

  return promisePipeline(download, gunzip, writer);
};

module.exports = { downloadUnzipAndWriteImdbFile, dependencies };
