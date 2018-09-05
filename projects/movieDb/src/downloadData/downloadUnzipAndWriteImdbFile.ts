import { pipeline, Writable } from 'stream';
import { promisify } from 'util';
import { createGunzip } from 'zlib';
import got from 'got';
import { existsSync, createWriteStream } from 'fs';

const promisePipeline = promisify(pipeline);

export const dependencies = {
  got,
  createGunzip,
  existsSync,
  createWriteStream,
};

export const downloadUnzipAndWriteImdbFile = (
  file: string,
  downloadPath: string,
  onDownloadProgress: ((progress: IProgress) => void),
  onFinish: (() => void),
): Promise<void> => {
  const unzippedFile = `${downloadPath}/${file.replace(/\.gz$/, '')}`;

  if (dependencies.existsSync(unzippedFile)) {
    onFinish();
    return Promise.resolve();
  }

  const download = dependencies.got
    .stream(`https://datasets.imdbws.com/${file}`)
    .on('downloadProgress', onDownloadProgress);

  const gunzip = dependencies.createGunzip();

  const writer = dependencies
    .createWriteStream(unzippedFile)
    .on('finish', onFinish);

  return promisePipeline(download, gunzip, writer);
};
