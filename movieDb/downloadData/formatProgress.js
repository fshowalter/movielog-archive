const { columnRight } = require('../reporter');

const bytesToMegabytes = bytes => Math.ceil(bytes / 1000000);

const formatProgress = (progress) => {
  const transferred = bytesToMegabytes(progress.transferred);
  const total = bytesToMegabytes(progress.total);

  return columnRight(`${transferred}/${total} MB`, 10);
};

module.exports = { formatProgress };
