const { types } = require('util');
const { gzipSync } = require('zlib');
const { Writable, Readable } = require('stream');
const nock = require('nock');
const { downloadUnzipAndWriteImdbFile, dependencies } = require('../downloadUnzipAndWriteImdbFile');

describe('downloadUnzipAndWriteImdbFile', () => {
  let imdb;
  let mockWriteStream;
  let written;

  beforeEach(() => {
    imdb = nock('https://datasets.imdbws.com');
    written = '';
    mockWriteStream = new Writable({
      write(chunk, encoding, callback) {
        written += chunk;
        callback();
      },
    });

    dependencies.createWriteStream = jest.fn().mockReturnValue(mockWriteStream);
  });

  describe('when unzipped file already exists', () => {
    beforeEach(() => {
      dependencies.existsSync = jest.fn().mockReturnValue(true);
    });

    it('returns a promise', () => {
      const result = downloadUnzipAndWriteImdbFile('testFile.gz', 'testPath/20180826', jest.fn(), jest.fn());
      expect(types.isPromise(result)).toEqual(true);
      expect(dependencies.existsSync).toBeCalledWith('testPath/20180826/testFile');
    });

    it('does not call onDownloadProgress callback', () => {
      const onDownloadProgress = jest.fn();
      downloadUnzipAndWriteImdbFile('testFile.gz', 'testPath/20180826', onDownloadProgress, jest.fn());
      expect(onDownloadProgress).not.toHaveBeenCalled();
    });

    it('calls onFinish callback', () => {
      const onFinish = jest.fn();
      downloadUnzipAndWriteImdbFile('testFile.gz', 'testPath/20180826', jest.fn(), onFinish);
      expect(onFinish).toHaveBeenCalled();
    });
  });

  describe('when unzipped file does not exist', () => {
    beforeEach(() => {
      dependencies.existsSync = jest.fn().mockReturnValue(false);
    });

    describe('when download is successful', () => {
      beforeEach(() => {
        const readable = new Readable();
        readable.push(gzipSync('Test Body'));
        readable.push(null);

        imdb.get('/testFile.gz').reply(200, () => readable);
      });

      it('returns a promise', () => {
        const result = downloadUnzipAndWriteImdbFile('testFile.gz', 'testPath/20180826', jest.fn(), jest.fn());
        expect(types.isPromise(result)).toEqual(true);
      });

      it('calls onDownloadProgress callback', () => {
        const onDownloadProgress = jest.fn();
        return downloadUnzipAndWriteImdbFile('testFile.gz', 'testPath/20180826', onDownloadProgress, jest.fn())
          .then(() => expect(onDownloadProgress).toHaveBeenCalled());
      });

      it('calls onFinish callback', () => {
        const onFinish = jest.fn();
        return downloadUnzipAndWriteImdbFile('testFile.gz', 'testPath/20180826', jest.fn(), onFinish)
          .then(() => expect(onFinish).toHaveBeenCalled());
      });

      it('unzips and writes the stream result', () => {
        const onFinish = jest.fn();
        return downloadUnzipAndWriteImdbFile('testFile.gz', 'testPath/20180826', jest.fn(), onFinish)
          .then(() => expect(written).toEqual('Test Body'));
      });
    });
  });
});
