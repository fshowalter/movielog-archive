const DraftLog = require('draftlog');

const dependencies = {
  DraftLog,
};

const createReporter = () => {
  if (!global.console.draft) {
    dependencies.DraftLog(global.console);
  }

  return global.console.draft();
};

const columnLeft = (text, length) => {
  if (text.length > length) {
    return text;
  }

  return text + ' '.repeat(length - text.length);
};

const columnRight = (text, length) => {
  if (text.length > length) {
    return text;
  }

  return ' '.repeat(length - text.length) + text;
};

module.exports = {
  createReporter,
  columnLeft,
  columnRight,
  dependencies,
};
