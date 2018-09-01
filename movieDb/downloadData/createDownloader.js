const { EventEmitter } = require('events');

const { ensureDownloadPath } = require('./ensureDownloadPath');
const { downloadUnzipAndWriteImdbFile } = require('./downloadUnzipAndWriteImdbFile');

const FILES_TO_DOWNLOAD = [
  'title.basics.tsv.gz',
  'title.principals.tsv.gz',
  'name.basics.tsv.gz',
];

const dependencies = {
  ensureDownloadPath,
  downloadUnzipAndWriteImdbFile,
};

const downloadFile = (file, downloadPath, emitter) => {
  const fileEventEmitter = new EventEmitter();

  const onDownloadProgress = (progress) => { fileEventEmitter.emit('progress', progress); };
  const onFinish = () => { fileEventEmitter.emit('done'); };

  emitter.emit('startFile', file, fileEventEmitter);

  return dependencies.downloadUnzipAndWriteImdbFile(
    file,
    downloadPath,
    onDownloadProgress,
    onFinish,
  );
};

const createDownloader = (emitter = new EventEmitter()) => ({
  emitter,
  on: (...args) => emitter.on(...args),
  start: async () => {
    const downloadPath = dependencies.ensureDownloadPath();
    emitter.emit('pathReady', downloadPath);

    const promises = FILES_TO_DOWNLOAD.map(
      file => downloadFile(file, downloadPath, emitter),
    );

    try {
      await Promise.all(promises);
      emitter.emit('done');
    } catch (error) {
      emitter.emit('error', error);
    }

    return downloadPath;
  },
});

module.exports = { createDownloader, dependencies };
