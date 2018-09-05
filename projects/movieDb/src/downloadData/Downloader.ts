import { StrictEventEmitter } from 'strict-event-emitter-types';

import { EventEmitter } from 'events';

import { ensureDownloadPath } from './ensureDownloadPath';
import { downloadUnzipAndWriteImdbFile } from './downloadUnzipAndWriteImdbFile';

const FILES_TO_DOWNLOAD = [
  'title.basics.tsv.gz',
  'title.principals.tsv.gz',
  'name.basics.tsv.gz',
];

export const dependencies = {
  ensureDownloadPath,
  downloadUnzipAndWriteImdbFile,
};

export interface DownloaderEvents {
  pathReady: string;
  error: (error: any) => void;
  done: void;
  startFile: (file: string, fileEventEmitter: FileDownloadEmitter) => void;
}

export interface FileDownloadEvents {
  progress: IProgress;
  done: void;
}

type DownloaderEmitter = StrictEventEmitter<EventEmitter, DownloaderEvents>;
type FileDownloadEmitter = StrictEventEmitter<EventEmitter, FileDownloadEvents>;

const downloadFile = (
  file: string,
  downloadPath: string,
  emitter: DownloaderEmitter,
) => {
  const fileEventEmitter: StrictEventEmitter<
    EventEmitter,
    FileDownloadEvents
  > = new EventEmitter();

  const onDownloadProgress = (progress: IProgress) => {
    fileEventEmitter.emit('progress', progress);
  };
  const onFinish = () => {
    fileEventEmitter.emit('done');
  };

  emitter.emit('startFile', file, fileEventEmitter);

  return dependencies.downloadUnzipAndWriteImdbFile(
    file,
    downloadPath,
    onDownloadProgress,
    onFinish,
  );
};

export class Downloader extends (EventEmitter as {
  new (): DownloaderEmitter;
}) {
  public async start(): Promise<string> {
    const downloadPath = dependencies.ensureDownloadPath();
    this.emit('pathReady', downloadPath);

    const promises = FILES_TO_DOWNLOAD.map(file =>
      downloadFile(file, downloadPath, this),
    );

    try {
      await Promise.all(promises);
      this.emit('done');
    } catch (error) {
      this.emit('error', error);
    }

    return downloadPath;
  }
}
