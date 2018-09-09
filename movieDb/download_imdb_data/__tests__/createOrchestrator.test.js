const { EventEmitter } = require('events');
const { createOrchestrator, dependencies } = require('../createOrchestrator');

describe('createOrchestrator', () => {
  let orchestrator;
  let downloader;

  beforeEach(() => {
    downloader = { start: jest.fn() };
    dependencies.createFileDownloader = jest.fn().mockReturnValue(downloader);
    dependencies.ensureDownloadPath = jest.fn().mockReturnValue('movieDbData');
    orchestrator = createOrchestrator();
    expect.assertions(1);
  });

  it('emits pathReady event with result of ensureDownloadPath', () => {
    orchestrator.on('pathReady', path => {
      expect(path).toEqual('movieDbData');
    });
    return orchestrator.start();
  });

  ['title.basics.tsv.gz', 'title.principals.tsv.gz', 'name.basics.tsv.gz'].forEach(file => {
    it(`calls createFileDownloader with ${file}`, () => {
      return orchestrator.start().then(() => {
        expect(dependencies.createFileDownloader).toBeCalledWith(file);
      });
    });

    it('emits a startFile event with a fileDownloader', () => {
      orchestrator.on('startFile', fileDownloader => {
        expect(fileDownloader).toBe(downloader);
      });

      return orchestrator.start();
    });

    describe('if download throws error', () => {
      let error;

      beforeEach(() => {
        error = new Error('download error');
        dependencies.createFileDownloader = jest.fn().mockRejectedValue(error);
      });

      it('emits error event', () => {
        orchestrator.on('error', errorValue => {
          expect(errorValue).toBe(error);
        });

        return downloader.start();
      });
    });
  });
});
