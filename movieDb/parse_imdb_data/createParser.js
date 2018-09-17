const { EventEmitter } = require('events');

const dependencies = {};

const createParser = () => {
  const emitter = new EventEmitter();

  return {
    on: (event, callback) => {
      emitter.on(event, callback);
    },
    start: async path => {
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

module.exports = { createParser, dependencies };
