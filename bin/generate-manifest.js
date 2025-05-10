const fs = require('fs');
const path = require('path');

function generateManifest(directory, manifestFile) {
  const files = [];

  function traverse(dir) {
    const items = fs.readdirSync(dir);
    for (const item of items) {
      const fullPath = path.join(dir, item);
      const stats = fs.statSync(fullPath);
      if (stats.isDirectory()) {
        traverse(fullPath);
      } else {
        // Calculate relative path
        const relativePath = path.relative(directory, fullPath).replace(/\\/g, '/'); // Normalize path
        files.push({ type: 'file', url: relativePath });
      }
    }
  }

  // Start traversal from the 'ccui' directory
  traverse(directory);

  // Convert the array to a JSON string
  const json = JSON.stringify(files, null, 2); // Pretty print

  // Write the JSON string to the manifest file
  fs.writeFileSync(manifestFile, json);
  console.log(`Manifest file generated successfully: ${manifestFile}`);
}

// Example usage:
const directoryToScan = 'ccui'; // The directory to scan
const manifestFileName = 'manifest.json';
generateManifest(directoryToScan, manifestFileName);