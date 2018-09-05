const { EventEmitter } = require('events');
const { createDownloader, dependencies } = require('../createDownloader');

describe('createDownloader', () => {
  let downloader;
  let emitter;

  it('creates an EventEmitter implementation if not provided', () => {
    downloader = createDownloader();
    expect(downloader.on).toBeInstanceOf(Function);
  });

  it('delegates on to the provided emitter', () => {
    emitter = { on: jest.fn() };
    downloader = createDownloader(emitter);

    const mockHandler = jest.fn();
    downloader.on('testEvent', mockHandler);
    expect(emitter.on).toBeCalledWith('testEvent', mockHandler);
  });

  describe('.start', () => {
    beforeEach(() => {
      dependencies.downloadUnzipAndWriteImdbFile = jest.fn();
      dependencies.ensureDownloadPath = jest.fn().mockReturnValue('movieDbData');
      emitter = { emit: jest.fn() };
      downloader = createDownloader(emitter);
    });

    it('emits onPathReady event with result of ensureDownloadPath', () => downloader.start()
      .then(() => {
        expect(emitter.emit).toBeCalledWith('pathReady', 'movieDbData');
      }));

    [
      'title.basics.tsv.gz',
      'title.principals.tsv.gz',
      'name.basics.tsv.gz',
    ].forEach((file) => {
      it(`calls downloadUnzipAndWriteImdbFile with ${file}`, () => downloader.start()
        .then(() => {
          expect(dependencies.downloadUnzipAndWriteImdbFile)
            .toBeCalledWith(file, 'movieDbData', expect.anything(), expect.anything());
        }));

      it('emits a startFile event with a file-specific emitter', () => downloader.start()
        .then(() => {
          expect(emitter.emit).toBeCalledWith('startFile', file, expect.any(EventEmitter));
        }));

      it('emits progress events to the file-specific emitter', () => downloader.start()
        .then(() => {
          const fileEmitter = emitter.emit.mock.calls.find(call => call[1] === file)[2];
          fileEmitter.emit = jest.fn();

          const onDownloadProgress = dependencies.downloadUnzipAndWriteImdbFile
            .mock.calls.find(call => call[0] === file)[2];

          const progress = { progress: 76, total: 147 };

          onDownloadProgress(progress);

          expect(fileEmitter.emit).toBeCalledWith('progress', progress);
        }));

      it('emits done event to the file-specific emitter', () => downloader.start()
        .then(() => {
          const fileEmitter = emitter.emit.mock.calls.find(call => call[1] === file)[2];
          fileEmitter.emit = jest.fn();

          const onFinish = dependencies.downloadUnzipAndWriteImdbFile
            .mock.calls.find(call => call[0] === file)[3];

          onFinish();

          expect(fileEmitter.emit).toBeCalledWith('done');
        }));

      describe('if download throws error', () => {
        let error;

        beforeEach(() => {
          error = new Error('download error');
          dependencies.downloadUnzipAndWriteImdbFile = jest.fn().mockRejectedValue(error);
        });

        it('emits error event', () => downloader.start()
          .then(() => {
            expect(emitter.emit).toBeCalledWith('error', error);
          }));
      });
    });
  });
});
