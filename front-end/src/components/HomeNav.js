import React, { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { connect, StringCodec } from "nats.ws";
import Button from '@mui/material/Button';
import LogoutIcon from '@mui/icons-material/Logout';
import AppBar from '@mui/material/AppBar';
import Box from '@mui/material/Box';
import Toolbar from '@mui/material/Toolbar';
import Typography from '@mui/material/Typography';
import { useSnackbar } from 'notistack';

const Nav = () => {
	const { enqueueSnackbar } = useSnackbar();
	const navigate = useNavigate();

	const logOut = () => {
		localStorage.removeItem("_id");
		navigate("/");
		if (nc !== undefined) {
			nc.close();
		}
		setConnection(undefined);
	};

	const posts = () => {
		navigate("/posts")
	}

	const [nc, setConnection] = useState(undefined);

	const addMessage = (err, msg) => {
		const newMessage = StringCodec().decode(msg.data);
		enqueueSnackbar(newMessage, { variant: "info", autoHideDuration: 5000 });
		console.info("Received a message: " + newMessage);
	};

	useEffect(() => {
		const id = localStorage.getItem("_id");
		const fetchData = async () => {
			try {
				const response = await fetch("http://localhost:4000/api/users/" + id);
				const data = await response.json();
				const subjects = data.subscribtions;
				if (nc === undefined) {
					connect({ servers: "ws://localhost:9090" })
						.then((nc) => {
							setConnection(nc);
							subjects.forEach((subject) => {
								nc.subscribe(subject, { callback: addMessage });
							});
						})
						.catch((err) => {
							console.log(err.message);
						});
				}
			} catch (error) {
				console.error('Error fetching data:', error);
			}
		};
		fetchData();
	}, [navigate]);

	return (
		<Box sx={{ flexGrow: 1 }}>
			<AppBar position="fixed" sx={{ bgcolor: "#585a5e" }} component="nav">
				<Toolbar>
					<Typography variant="h6" component="div" sx={{ flexGrow: 1 }}>
						<img src="images/bal.svg" alt='Bal Logo' height='15' /> Forum
					</Typography>
					<Button variant="contained" size="medium" onClick={posts} sx={{ bgcolor: "#20b6b0", marginRight: "10px" }}>Create Post</Button>
					<Button variant="contained" size="medium" onClick={logOut} endIcon={<LogoutIcon />} sx={{ bgcolor: "#20b6b0" }}>Log out</Button>
				</Toolbar>
			</AppBar>
		</Box>
	);
};

export default Nav;
