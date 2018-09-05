import { existsSync, mkdirSync } from 'fs';

export const dependencies = {
  existsSync,
  mkdirSync,
};

const DOWNLOAD_DIR = 'movieDbData';

export const ensureDownloadPath = (): string => {
  const zeroPad = (number: number): string =>
    number.toString().padStart(2, '0');

  const date = new Date(Date.now());
  const year = date.getFullYear();
  const month = zeroPad(date.getMonth() + 1);
  const day = zeroPad(date.getDate());
  const path = `${DOWNLOAD_DIR}/${year}${month}${day}`;

  if (!dependencies.existsSync(path)) {
    dependencies.mkdirSync(path);
  }

  return path;
};
