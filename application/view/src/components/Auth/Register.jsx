// src/pages/Register.jsx
import React, { useState } from 'react';
import { Link,useHistory } from 'react-router-dom';
import http from '../../http';


function Register() {
  const [form, setForm] = useState({ email: '', password: '' });
  const [message, setMessage] = useState('');
  const history = useHistory();

  const handleChange = e => setForm({ ...form, [e.target.name]: e.target.value });


  const handleSubmit = async (event) => {
    event.preventDefault();


    try {
      // const response = await fetch('/api/Auth/register', {
        
      //   method: 'POST',
      //   headers: {
      //     'Content-Type': 'application/json'
      //   },
      //   body: JSON.stringify(form)
      // });
      const response = await http.post('/Auth/register', form)
      console.log('Response:', response);
      const responseText = await response.statusText;

      if (!response.status === 200) {
        console.error("Error details:", responseText);
        setMessage("Registration failed: " + responseText);
        return;
      }

      
      // Step 2: Auto-login
      const loginResponse = await http.post('/Auth/login', form, {
        headers: {
          'Content-Type': 'application/json',
        },
      });


      const loginText = await loginResponse.statusText;

      if (!loginResponse.status === 200) {
        console.error("Auto-login failed:", loginText);
        setMessage("Auto-login failed: " + loginText);
        return;
      }

      console.log("Login success:", loginText);

      // Step 3: Redirect to /product
      history.push('/product');


    } catch (error) {
      console.error("Could not post data: ", error);
    }
  };

  return (
    
    <div className="auth-container">
      <h2 className="auth-title">Register</h2>
      <form className="auth-form" onSubmit={handleSubmit}>
        <input
          className="auth-input"
          type="email"
          name="email"
          placeholder="Email"
          onChange={handleChange}
          required
        />
        <input
          className="auth-input"
          type="password"
          name="password"
          placeholder="Password"
          onChange={handleChange}
          required
        />
        {/* <input
          className="auth-input"
          type="password"
          name="confirmPassword"
          placeholder="Confirm Password"
          onChange={handleChange}
          required
        /> */}
        <button className="auth-button" type="submit">Register</button>
        <p className="auth-message">{message}</p>
      </form>
    </div>
  );
}

export default Register;
