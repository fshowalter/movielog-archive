const { createOrchestrator, dependencies } = require('../createOrchestrator');

describe('createOrchestrator', () => {
  let orchestrator;
  let fileEmitters;

  beforeEach(() => {
    fileEmitters = {};
    dependencies.downloadUnzipAndWriteImdbFile = jest.fn();
    dependencies.ensureDownloadPath = jest.fn().mockReturnValue('movieDbData');
    orchestrator = createOrchestrator();

    orchestrator.on('startFile', ({ file, emitter }) => {
      fileEmitters[file] = emitter;
    });
  });

  afterEach(() => {
    expect.hasAssertions();
  });

  it('emits pathReady event with result of ensureDownloadPath', () => {
    let emittedValue;

    orchestrator.on('pathReady', path => {
      emittedValue = path;
    });

    return orchestrator.start().then(() => {
      expect(emittedValue).toBe('movieDbData');
    });
  });

  it('emits 3 startFile events with unique emitters', () => {
    return orchestrator.start().then(() => {
      expect(Object.keys(fileEmitters).length).toBe(3);
      expect(new Set(Object.values(fileEmitters)).size).toBe(3);
    });
  });

  it('calls downloadUnzipAndWriteImdbFile with emitter emitted by the startFile event', () => {
    return orchestrator.start().then(() => {
      Object.keys(fileEmitters).forEach(file => {
        expect(dependencies.downloadUnzipAndWriteImdbFile).toBeCalledWith({
          file,
          path: 'movieDbData',
          emitter: fileEmitters[file]
        });
      });
    });
  });

  describe('if download throws error', () => {
    let error;

    beforeEach(() => {
      error = new Error('download error');
      dependencies.downloadUnzipAndWriteImdbFile = jest
        .fn()
        .mockResolvedValueOnce('first file')
        .mockRejectedValueOnce(error);
    });

    it('emits error event', () => {
      orchestrator.on('error', errorValue => {
        expect(errorValue).toBe(error);
      });

      return orchestrator.start();
    });
  });
});
