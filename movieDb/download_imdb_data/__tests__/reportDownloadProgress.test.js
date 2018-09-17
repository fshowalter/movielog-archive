const { EventEmitter } = require('events');
const chalk = require('chalk');
const { reportDownloadProgress, dependencies } = require('../reportDownloadProgress');

describe('reportDownloadProgress', () => {
  let options;
  let draftlog;

  beforeEach(() => {
    chalk.enabled = false;
    draftlog = jest.fn();

    dependencies.DraftLog = jest.fn(() => {
      global.console.draft = draftlog;
    });

    options = { file: 'testFileName', emitter: new EventEmitter() };

    reportDownloadProgress(options);
  });

  afterEach(() => {
    chalk.enabled = true;
    expect.hasAssertions();
  });

  describe('on progress event', () => {
    beforeEach(() => {
      const progress = {
        transferred: 66004530,
        total: 1760983006
      };

      options.emitter.emit('progress', progress);
    });

    it('logs draftlog message', () => {
      expect(draftlog).toBeCalledWith('testFileName                  67M/1761M');
    });
  });

  describe('on done event', () => {
    beforeEach(() => {
      options.emitter.emit('done');
    });

    it('logs draftlog message', () => {
      expect(draftlog).toBeCalledWith('testFileName                  Done!');
    });
  });
});
