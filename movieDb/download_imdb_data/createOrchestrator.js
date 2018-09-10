const { EventEmitter } = require('events');
const { ensureDownloadPath } = require('./ensureDownloadPath');
const { downloadUnzipAndWriteImdbFile } = require('./downloadUnzipAndWriteImdbFile');

const FILES_TO_DOWNLOAD = ['title.basics.tsv.gz', 'title.principals.tsv.gz', 'name.basics.tsv.gz'];

const dependencies = {
  ensureDownloadPath,
  downloadUnzipAndWriteImdbFile
};

const createOrchestrator = () => {
  const emitter = new EventEmitter();

  return {
    on: (event, callback) => {
      emitter.on(event, callback);
    },
    start: async () => {
      const downloadPath = dependencies.ensureDownloadPath();
      emitter.emit('pathReady', downloadPath);

      const promises = FILES_TO_DOWNLOAD.map(file => {
        const fileEmitter = new EventEmitter();
        emitter.emit('startFile', { file, emitter: fileEmitter });
        return dependencies.downloadUnzipAndWriteImdbFile({
          file,
          path: downloadPath,
          emitter: fileEmitter
        });
      });

      try {
        await Promise.all(promises);
        emitter.emit('done');
      } catch (error) {
        emitter.emit('error', error);
      }

      return downloadPath;
    }
  };
};

module.exports = { createOrchestrator, dependencies };
