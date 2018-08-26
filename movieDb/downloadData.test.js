const { Readable, Writable } = require('stream');
const { dependencies, downloadData } = require('./downloadData');

const testDate = new Date(2018, 7, 25);
const RealDate = Date;

dependencies.DraftLog = jest.fn();
dependencies.exec = jest.fn((command, callback) => callback());

dependencies.got = {
  stream: jest.fn(),
};

dependencies.fs = {
  existsSync: jest.fn(),
  mkdirSync: jest.fn(),
  createWriteStream: jest.fn(),
};

const imdbUrl = 'https://datasets.imdbws.com';

describe('downloadData', () => {
  let mockWriteStream;
  let mockReadStream;
  let consoleSpy;

  beforeAll(() => {
    consoleSpy = jest.spyOn(global.console, 'log').mockImplementation(() => null);
  });

  afterAll(() => {
    consoleSpy.mockRestore();
  });

  beforeEach(() => {
    mockReadStream = new Readable({ read: () => { } });
    mockWriteStream = new Writable({ write: () => { } });

    dependencies.got.stream.mockReturnValue(mockReadStream);
    dependencies.fs.createWriteStream.mockReturnValue(mockWriteStream);

    global.Date.now = jest.fn(() => testDate.getTime());
    global.console.draft = jest.fn(() => jest.fn());
  });

  afterEach(() => {
    global.Date = RealDate;
  });

  describe('when downloaddir does not exist', () => {
    beforeEach(() => {
      dependencies.fs.existsSync.mockReturnValue(false);
    });

    it('makes a directory', (done) => {
      downloadData().then(() => {
        expect(dependencies.fs.mkdirSync).toBeCalledWith('movieDbData/20180825');
        done();
      });

      mockWriteStream.emit('finish');
    });

    [
      'title.basics.tsv.gz',
      'title.principals.tsv.gz',
      'name.basics.tsv.gz',
    ].forEach((title) => {
      it(`tries to download ${title}`, (done) => {
        downloadData().then(() => {
          expect(dependencies.got.stream).toBeCalledWith(`${imdbUrl}/${title}`);
          done();
        });

        mockWriteStream.emit('finish');
      });
    });
  });
});
