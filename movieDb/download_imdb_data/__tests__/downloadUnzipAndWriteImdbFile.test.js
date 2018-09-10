const { types } = require('util');
const { gzipSync } = require('zlib');
const { Writable, Readable } = require('stream');
const nock = require('nock');
const { downloadUnzipAndWriteImdbFile, dependencies } = require('../downloadUnzipAndWriteImdbFile');

describe('downloadUnzipAndWriteImdbFile', () => {
  let imdb;
  let mockEmitter;
  let mockWriteStream;
  let written;
  let options;

  beforeEach(() => {
    mockEmitter = {
      emit: jest.fn()
    };

    imdb = nock('https://datasets.imdbws.com');
    written = '';
    mockWriteStream = new Writable({
      write(chunk, encoding, callback) {
        written += chunk;
        callback();
      }
    });

    dependencies.existsSync = jest.fn();
    dependencies.createWriteStream = jest.fn().mockReturnValue(mockWriteStream);

    options = {
      file: 'testFile.gz',
      path: 'testPath/20180826',
      emitter: mockEmitter
    };
  });

  afterEach(() => {
    expect.hasAssertions();
  });

  describe('when unzipped file already exists', () => {
    beforeEach(() => {
      dependencies.existsSync.mockReturnValue(true);
    });

    it('returns a promise', () => {
      expect(types.isPromise(downloadUnzipAndWriteImdbFile(options))).toEqual(true);
    });

    it('does not emit progress event', () => {
      return downloadUnzipAndWriteImdbFile(options).then(() => {
        expect(mockEmitter.emit).not.toHaveBeenCalledWith('progress', expect.anything());
      });
    });

    it('emits done event', () => {
      return downloadUnzipAndWriteImdbFile(options).then(() => {
        expect(mockEmitter.emit).not.toHaveBeenCalledWith('done', expect.anything());
      });
    });
  });

  describe('when unzipped file does not exist', () => {
    beforeEach(() => {
      dependencies.existsSync.mockReturnValue(false);
    });

    describe('when download is successful', () => {
      beforeEach(() => {
        const readable = new Readable();
        readable.push(gzipSync('Test Body'));
        readable.push(null);

        imdb.get('/testFile.gz').reply(200, () => readable);
      });

      it('returns a promise', () => {
        expect(types.isPromise(downloadUnzipAndWriteImdbFile(options))).toEqual(true);
      });

      it('emits progress event', () => {
        return downloadUnzipAndWriteImdbFile(options).then(() => {
          expect(mockEmitter.emit).toHaveBeenCalledWith('progress', {
            percent: 1,
            total: null,
            transferred: 29
          });
        });
      });

      it('emits done event', () => {
        return downloadUnzipAndWriteImdbFile(options).then(() => {
          expect(mockEmitter.emit).toHaveBeenCalledWith('done');
        });
      });

      it('unzips and writes the stream result', () => {
        return downloadUnzipAndWriteImdbFile(options).then(() => {
          expect(written).toEqual('Test Body');
        });
      });
    });
  });
});
