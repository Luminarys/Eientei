export default React.createClass({
  getInitialState: function() {
    return {percent: 0};
  },

  handleUploadProgress: function (event) {
    if (event.lengthComputable) {
      const progressPercent = Math.floor((event.loaded / event.total) * 100);
      this.setState({percent: progressPercent});
    }
  },

  handleUploadComplete: function(event) {
  },

  componentDidMount: function() {
    const xhr = new XMLHttpRequest();
    xhr.open('POST', '/api/upload');

    xhr.addEventListener('load', this.handleUploadComplete, false);
    xhr.upload.onprogress = this.handleUploadProgress;

    const form = new FormData();
    form.append('file', this.props.file);
    xhr.send(form);
  },

  render: function() {
    return (
      <tr>
        <td>
          {this.props.name}
        </td>
        <td>
          <div className='progress'>
            <div className='progress-bar' style={{width: this.state.percent + '%'}}>
              {this.state.percent + '%'}
            </div>
          </div>
        </td>
      </tr>
    );
  }
});
