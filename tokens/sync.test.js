import { test } from 'node:test';
import assert from 'node:assert/strict';
import { flattenTokens } from './sync.js';

test('flattenTokens flattens nested token groups into kebab names', () => {
  const input = {
    amber: {
      '500': { $type: 'color', $value: '#F59E0B' },
    },
  };
  assert.deepEqual(flattenTokens(input), { 'amber-500': '#F59E0B' });
});

test('flattenTokens respects explicit prefix', () => {
  const input = {
    canvas: { $type: 'color', $value: '#0A0A0B' },
  };
  assert.deepEqual(flattenTokens(input, 'dark'), { 'dark-canvas': '#0A0A0B' });
});

test('flattenTokens ignores $type/$description, only reads $value', () => {
  const input = {
    status: {
      success: { $type: 'color', $value: '#10B981', $description: 'healthy' },
    },
  };
  assert.deepEqual(flattenTokens(input), { 'status-success': '#10B981' });
});
