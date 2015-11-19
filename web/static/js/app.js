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
  progress.className = 'progress';

  const progressBar = document.createElement('div');
  progressBar.style.width = '0%';
  progressBar.textContent = '0%';
  progressBar.className = 'progress-bar';

  progress.appendChild(progressBar);

  progressCell.appendChild(progress);

  row.appendChild(name);
  row.appendChild(progressCell);

  document.getElementById('files').appendChild(row);
  return progressCell;
}

function handleUploadProgress(evt) {
  console.log(evt);
  const xhr = evt.target;
  console.log(xhr);
  const bar = xhr.bar;
  console.log(bar);
  if (evt.lengthComputable) {
    const progressPercent = Math.floor((evt.loaded / evt.total) * 100);
    bar.style.width = [progressPercent, '%'].join('');
    bar.textContent = [progressPercent, '%'].join('');
   }
}

function handleUploadComplete(evt) {
  const xhr = evt.target;
  const respStatus = xhr.status;
  const progress = xhr.progress;
  switch (xhr.status) {
    case 200:
      const response = JSON.parse(xhr.responseText).file;
      if (response.success) {
        progress.innerHTML = ['<a href="', response.url, '" target="_BLANK">', response.name, '</a>'].join('');
      } else {
        progress.innerHTML = ['Error: ', response.reason].join('');
      }
      return;
    case 413:
      progress.innerHTML = 'I-it\'s too big Onii-chan!';
      return;
    case 429:
      progress.innerHTML = 'T-too much Onii-chan!';
      return;
    default:
      progress.innerHTML = 'Server error!';
      return;
  }
};

function uploadFile(file, progress) {
  const bar = progress.querySelector('.progress-bar');
  const xhr = new XMLHttpRequest();
  xhr.open('POST', '/api/upload');
  xhr['progress'] = progress;
  xhr.upload["bar"] = bar;

  xhr.addEventListener('load', handleUploadComplete, false);
  xhr.upload.onprogress = handleUploadProgress;

  const form = new FormData();
  form.append('file', file);
  xhr.send(form);
}

function dragNOP(evt) {
  evt.stopPropagation();
  evt.preventDefault();
}

function handleDragDrop(evt) {
  dragNOP(evt);
  for (let file of evt.dataTransfer.files) {
    const row = addRow(file);
    uploadFile(file, row);
  }
}

function uploadFiles() {
  // mfw no iterators
  const len = browse.files.length;
  for (let i = 0; i < len; i++) {
    const file = browse.files[i];
    const row = addRow(file);
    uploadFile(file, row);
  }
}

function selectFiles(evt) {
  evt.preventDefault();
  browse.click();
}

window.addEventListener('dragenter', dragNOP, false);
window.addEventListener('dragleave', dragNOP, false);
window.addEventListener('dragover', dragNOP, false);
window.addEventListener('drop', handleDragDrop, false);

browse.addEventListener('change', uploadFiles);

document.querySelector('.target').addEventListener('click', selectFiles);

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
