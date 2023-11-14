import * as React from 'react'
import styled from 'styled-components';
import Paper from '@mui/material/Paper';

const ConsolePaper = styled(Paper)`
    // box-sizing: border-box;
    width: 100%;
    height: 400px;
    overflow: auto;
    padding: 1em;
`;

function Console ({ content }) {
    return (
        <ConsolePaper variant="outlined">
            <pre>{content}</pre>
        </ConsolePaper>
    );
}

export default Console;