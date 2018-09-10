const { EventEmitter } = require('events');
const chalk = require('chalk');
const { createReporter, dependencies } = require('../createReporter');

describe('createReporter', () => {
  let consoleSpy;
  let mockOrchestrator;

  beforeEach(() => {
    chalk.enabled = false;
    consoleSpy = jest.spyOn(global.console, 'log').mockImplementation(() => null);

    dependencies.reportDownloadProgress = jest.fn();

    mockOrchestrator = new EventEmitter();
    createReporter(mockOrchestrator);
  });

  afterEach(() => {
    chalk.enabled = true;
    consoleSpy.mockRestore();
    expect.hasAssertions();
  });

  describe('on pathReady event', () => {
    beforeEach(() => {
      mockOrchestrator.emit('pathReady', 'testPath');
    });

    it('logs console message', () => {
      expect(global.console.log).toBeCalledWith('Downloading to testPath...');
    });
  });

  describe('on done event', () => {
    beforeEach(() => {
      mockOrchestrator.emit('done');
    });

    it('logs console message', () => {
      expect(global.console.log).toBeCalledWith('All files downloaded!');
    });
  });

  describe('on startFile event', () => {
    let startFileArgs;

    beforeEach(() => {
      startFileArgs = { file: 'testFile', emitter: new EventEmitter() };
      mockOrchestrator.emit('startFile', startFileArgs);
    });

    it('logs console message', () => {
      expect(dependencies.reportDownloadProgress).toBeCalledWith(startFileArgs);
    });
  });
});
