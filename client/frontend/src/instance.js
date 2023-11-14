import axios from 'axios';

const API_ROOT = process.env.REACT_APP_API_ROOT || 'http://localhost:4000/api';

const instance = axios.create({
    baseURL: API_ROOT,
    timeout: 5000, // millisec => 5 sec
    headers: {
        'Content-Type': 'application/json'
    }
});

export default instance;
