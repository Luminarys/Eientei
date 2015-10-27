// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in 'brunch-config.js'.
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from 'config.paths.watched'.
import 'deps/phoenix_html/web/static/js/phoenix_html';

// Import local files
//
// Local files can be imported directly using relative
// paths './socket' or full ones 'web/static/js/socket'.

// import socket from './socket'

// var paste = document.getElementById('paste');
// var pasteBtn = document.getElementById('paste-btn');

const browse = document.getElementById('browse');

function addRow(file) {
  const row = document.createElement('tr');
  const name = document.createElement('td');
  name.textContent = file.name;
  const progressCell = document.createElement('td');
  const progress = document.createElement('div');
  progressCell.appendChild(progress);
  progress.className = 'progress';
  const progressBar = document.createElement('div');
  progressBar.style.width = '0%';
  progressBar.textContent = '0%';
  progressBar.className = 'progress-bar';
  progress.appendChild(progressBar);
  row.appendChild(name);
  row.appendChild(progressCell);
  document.getElementById('files').appendChild(row);
  return progressCell;
}

function uploadFile(file, progress) {
  const bar = progress.querySelector('.progress-bar');
  const xhr = new XMLHttpRequest();
  xhr.open('POST', '/api/upload');

  xhr.onload = function xhrLoader() {
    const respStatus = xhr.status;
    if (respStatus === 200) {
      const response = JSON.parse(xhr.responseText);
      if (response.success) {
        progress.innerHTML = '<a href="' + response.url + '">' + response.name + '</a>';
      } else {
        progress.innerHTML = 'Error: ' + response.reason;
      }
    } else if (respStatus === 413) {
      progress.innerHTML = 'File too big!';
    } else {
      progress.innerHTML = 'Server error!';
    }
  };

  xhr.upload.onprogress = function incProgress(progEvent) {
    if (progEvent.lengthComputable) {
      const progressPercent = Math.floor((progEvent.loaded / progEvent.total) * 100);
      bar.style.width = progressPercent + '%';
      bar.textContent = progressPercent + '%';
    }
  };

  const form = new FormData();
  form.append('key', window.api_key);
  form.append('file', file);
  xhr.send(form);
}

function dragNOP(dragNOPEvent) {
  dragNOPEvent.stopPropagation();
  dragNOPEvent.preventDefault();
}

function handleDragDrop(dragDropEvent) {
  dragNOP(dragDropEvent);
  const len = dragDropEvent.dataTransfer.files.length;
  for (let i = 0; i < len; i++) {
    const file = dragDropEvent.dataTransfer.files[i];
    const row = addRow(file);
    uploadFile(file, row);
  }
}

window.addEventListener('dragenter', dragNOP, false);
window.addEventListener('dragleave', dragNOP, false);
window.addEventListener('dragover', dragNOP, false);
window.addEventListener('drop', handleDragDrop, false);

browse.addEventListener('change', function onChange() {
  const len = browse.files.length;
  for (let i = 0; i < len; i++) {
    const file = browse.files[i];
    const row = addRow(file);
    uploadFile(file, row);
  }
});

document.querySelector('.target').addEventListener('click', function doClick(clickEvent) {
  clickEvent.preventDefault();
  browse.click();
});

/*
  paste.addEventListener('keydown', function() {
    pasteBtn.style.display = 'block';
  });
  pasteBtn.addEventListener('click', function(e) {
    e.preventDefault();
    var blob = new Blob([paste.value], {type: 'text/plain'});
    var file = new File([blob], 'paste.txt');
    var progress = addRow(file);
    uploadFile(file, progress);
  });
/**/
