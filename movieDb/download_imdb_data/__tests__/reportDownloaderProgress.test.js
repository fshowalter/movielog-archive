const { EventEmitter } = require('events');
const chalk = require('chalk');
const { reportDownloaderProgress, dependencies } = require('../reportDownloaderProgress');

describe('reportDownloaderProgress', () => {
  let consoleSpy;
  let downloader;

  beforeEach(() => {
    chalk.enabled = false;
    consoleSpy = jest.spyOn(global.console, 'log').mockImplementation(() => null);
    dependencies.DraftLog = jest.fn(() => { global.console.draft = jest.fn(); });
    downloader = new EventEmitter();
    reportDownloaderProgress(downloader);
  });

  afterEach(() => {
    chalk.enabled = true;
    delete global.console.draft;
    consoleSpy.mockRestore();
  });

  [
    'pathReady',
    'startFile',
    'done',
  ].forEach((event) => {
    it(`registers ${event} event`, () => {
      expect(downloader.listeners(event).length).toBe(1);
    });
  });

  describe('onPathReady', () => {
    beforeEach(() => {
      downloader.emit('pathReady', 'testPath');
    });

    it('logs console message', () => {
      expect(global.console.log).toBeCalledWith('Downloading to testPath...');
    });
  });

  describe('onDone', () => {
    beforeEach(() => {
      downloader.emit('done');
    });

    it('logs console message', () => {
      expect(global.console.log).toBeCalledWith('All files downloaded!');
    });
  });

  describe('onStartFile', () => {
    let fileEmitter;
    let draftlog;

    beforeEach(() => {
      fileEmitter = new EventEmitter();
      draftlog = jest.fn();
      global.console.draft.mockReturnValue(draftlog);
      downloader.emit('startFile', 'testFileName', fileEmitter);
    });

    [
      'progress',
      'done',
    ].forEach((event) => {
      it(`registers ${event} event`, () => {
        expect(fileEmitter.listeners(event).length).toBe(1);
      });
    });

    describe('onFileProgress', () => {
      beforeEach(() => {
        const progress = {
          transferred: 66004530,
          total: 1760983006,
        };
        fileEmitter.emit('progress', progress);
      });

      it('logs draftlog message', () => {
        expect(draftlog).toBeCalledWith('testFileName                  67/1761 MB');
      });
    });

    describe('onFileDone', () => {
      beforeEach(() => {
        fileEmitter.emit('done');
      });

      it('logs draftlog message', () => {
        expect(draftlog).toBeCalledWith('testFileName                  Done!');
      });
    });
  });
});
