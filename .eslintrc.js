module.exports = {
  extends: ['airbnb', 'prettier'],
  plugins: ['jest', 'prettier'],
  env: {
    'jest/globals': true
  },
  rules: {
    'prettier/prettier': ['error']
  }
};
