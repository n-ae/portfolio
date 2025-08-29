module.exports = {
  env: {
    node: true,
    es2021: true,
    jest: true
  },
  extends: [
    'standard'
  ],
  parserOptions: {
    ecmaVersion: 12,
    sourceType: 'module'
  },
  rules: {
    // Custom rules for CLI project
    'no-console': 'off', // Console output is expected in CLI
    'no-process-exit': 'off', // Process exits are expected in CLI
    'space-before-function-paren': ['error', 'always'],
    'comma-dangle': ['error', 'never']
  },
  overrides: [
    {
      files: ['*.test.js'],
      rules: {
        'no-unused-expressions': 'off' // Jest expects expressions
      }
    }
  ]
}
