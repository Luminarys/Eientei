import FileUpload from "./FileUpload";

export default React.createClass({
  getInitialState: function() {
    return {files: []};
  },

  handleFilesSelected: function(event) {
    const files = event.target.files;
    const len = files.length;
    let fileArr = [];
    for (let i = 0; i < len; i++) {
      fileArr[i] = files[i];
    }
    this.setState({files: fileArr});
  },

  render: function() {
    return (
      <div>
        <input id='browse' className='hidden' type='file' onChange={this.handleFilesSelected} />
          <table className='table'>
              <thead>
                <tr>
                  <td style={{width: '30%'}}></td>
                  <td style={{width: '70%'}}></td>
                </tr>
              </thead>
              <tbody id="files">
                {
                  this.state.files.map(function(file, ind) {
                    return (
                      <FileUpload key={ind} name={file.name} file={file} />
                    );
                  }, this)
                }
          </tbody>
        </table>
      </div>
    );
  }
});
