import React,{ useState } from 'react';
import Login from '../Auth/Login';
import Register from '../Auth/Register';
import './Main.css'; // make sure this path is correct

function Main() {
  const [showLogin, setShowLogin] = useState(true);

  const handleSwitchToRegister = () => {
    setShowLogin(false);
  };
  return (
    <div className="landing-container">
      <div className="left-section">
        <div className="headline">
          <p>
            Web Design & <br />
            <span>Development</span>
          </p>
        </div>
        <div className="description">
          <p>
            Welcome to our platform. Build, deploy, and scale with confidence.
          </p>
          <button className="cta-button" onClick={handleSwitchToRegister}>Join Us</button>
         
        </div>
      </div>

      <div className="right-section">
        <div className="auth-box">
          {/* <Login /> */}
          {showLogin ? <Login onSwitchToRegister={handleSwitchToRegister} /> : <Register />}
        </div>
      </div>
    </div>
  );
}

export default Main;
