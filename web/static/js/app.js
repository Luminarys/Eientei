import 'deps/phoenix_html/web/static/js/phoenix_html';

let uploadButton = {
  controller() {
    let ctrl = this;
    ctrl.message = m.prop("Select or drop file(s)");
  },
  view(ctrl, args) {
    return m(".target", {
      onclick: function(e) {
        document.getElementById('browse').click();
      },
      ondrop: function(e) {
        args.files(args.serializer(e.dataTransfer.files));
      },
      ondragover: function(e) {
        e.preventDefault();
      }
    }, ctrl.message());
  }
}

let fileUpload = {
  handleUploadProgress(event) {
    if (event.lengthComputable) {
      const progressPercent = Math.floor((event.loaded / event.total) * 100);
      this.state.percent(progressPercent);
      m.redraw();
    }
  },
  handleUploadComplete(event) {
    const xhr = event.target;
    let error = function(message) {
      this.state.complete(true);
      this.state.error(true);
      this.state.message(message);
    };
    switch (xhr.status) {
      case 200:
        const resp = JSON.parse(xhr.responseText).file;
        if (resp.success) {
          this.state.complete(true);
          this.state.message(resp.url);
        } else {
          error(resp.reason);
        }
        break;
      case 413:
          error("I-it's too big Onii-chan! Use a smaller file!");
        break;
      case 429:
          error("I-it's too much Onii-chan! Stop uploading so much!");
        break;
      default:
          error("S-something went wrong!");
        break;
    }
    m.redraw();
  },
  controller(args) {
    this.state = {
      percent: m.prop(0),
      complete: m.prop(false),
      error: m.prop(false),
      message: m.prop(""),
      name: m.prop(args.key)
    };

    // Dispatch XHR req on mount
    const xhr = new XMLHttpRequest();
    xhr.open('POST', '/api/upload');

    xhr.addEventListener('load', fileUpload.handleUploadComplete.bind(this), false);
    xhr.upload.onprogress = fileUpload.handleUploadProgress.bind(this);

    const form = new FormData();
    form.append('file', args.file);
    xhr.send(form);
  },
  view(ctrl, args) {

    let leftCol = m("div");
    if (ctrl.state.complete()) {
      if (ctrl.state.error()) {
        leftCol = ctrl.state.message();
      } else {
        leftCol = m("a", {href: ctrl.state.message()}, ctrl.state.message());
      }
    } else {
      leftCol =
        m("div.progress", [
          m("div.progress-bar", {
            style: {
              width: ctrl.state.percent() + "%"
            }
          }, ctrl.state.percent() + "%")
        ]);
    }
    return m("tr", [
      m("td", ctrl.state.name()),
      m("td", [leftCol]),
    ]);
  }
};

let uploader = {
  controller() {
    let ctrl = this;
    ctrl.files = m.prop([]);
    ctrl.getFileArray = function(files) {
      let fileArr = [];
      const len = files.length;
      for (let i = 0; i < len; i++) {
        fileArr[i] = files[i];
      }
      return fileArr;
    };
  },
  view(ctrl) {
    return m("div", [
      m.component(uploadButton, {files: ctrl.files, serializer: ctrl.getFileArray}),
      m("input#browse.hidden", {
        type: "file",
        multiple: "true",
        onchange: function(e) {
          const files = ctrl.getFileArray(e.target.files);
          // Force clear the DOM to remount stuff
          ctrl.files([]);
          m.redraw();
          ctrl.files(files);
        }
      }),
      m("table.table", [
        m("thead", [
          m("tr", [
            m("td", {
              style: {width: '30%'}
            }),
            m("td", {
              style: {width: '70%'}
            })
          ])
        ]),
        m("tbody#files", ctrl.files().map(function(res) {
          return m.component(fileUpload, {file: res, key: res.name});
        }))
      ])
    ]);
  }
};

m.mount(document.getElementById('uploadForm'), uploader);

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
