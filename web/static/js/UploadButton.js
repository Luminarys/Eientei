export default React.createClass({
  handleClick: function(event) {
    event.preventDefault();
    document.getElementById('browse').click();
  },

  render: function() {
    return (
      <a onClick={this.handleClick} href="#" className="target">
        Select or drop file(s)
      </a>
    );
  }
});
