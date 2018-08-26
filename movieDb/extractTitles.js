const csv = require('csv-parser');

const titleTransform = (accumulator, currentValue) => {
  if (currentValue.isAdult === '1' || currentValue.titleType !== 'movie') {
    return accumulator;
  }

  console.log(currentValue.genres);
  console.log(currentValue.genres.includes('Documentary'));

  accumulator[currentValue.tconst] = {
    primaryTitle: currentValue.primaryTitle,
    originalTitle: currentValue.originalTitle,
    year: currentValue.startYear,
    runtimeMinutes: currentValue.runtimeMinutes,
  };

  return accumulator;
};

const parseFile = async (file, transform, values) => {
  dependencies.fs.createReadStream(file)
    .pipe(dependencies.csv({ separator: '\t' }))
    .on('data', (data) => {
      values = transform(initialValue)
    })

  return jsonArray.reduce(transform, initialValue);
};