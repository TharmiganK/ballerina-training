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
	};

	const posts = () => {
		navigate("/posts")
	}

	const [nc, setConnection] = useState(undefined);
	const [lastError, setLastError] = useState("");

	const addMessage = (err, msg) => {
		const newMessage = StringCodec().decode(msg.data);
		enqueueSnackbar(newMessage, { variant: "info", autoHideDuration: 10000 });
		console.info("Received a message: " + newMessage);
	};

	useEffect(() => {
		const id = localStorage.getItem("_id");
		const fetchData = async () => {
			try {
				const response = await fetch("http://localhost:4000/api/users/" + id);
				const data = await response.json();
				const subjects = data.user.subscribtions;
				console.log(subjects);
				if (nc == undefined) {
					connect({ servers: "ws://localhost:9090" })
						.then((nc) => {
							setConnection(nc);
							subjects.forEach((subject) => {
								nc.subscribe(subject, { callback: addMessage });
							});
						})
						.catch((err) => {
							setLastError(err.message);
						});
				}
			} catch (error) {
				console.error('Error fetching data:', error);
			}
		};
		fetchData();
		// const id = localStorage.getItem("_id");

		// if (nc == undefined) {
		// 	connect({ servers: "ws://localhost:9090" })
		// 		.then((nc) => {
		// 			setConnection(nc);
		// 			fetch("http://localhost:4000/api/users/" + id)
		// 				.then((res) => {
		// 					if (res.status === 200) {
		// 						return res.json();
		// 					}
		// 					throw new Error("Something went wrong", res.json());
		// 				})
		// 				.then((data) => {
		// 					console.log(data.user.subscriptions);
		// 				})
		// 				.catch((err) => console.error(err));
		// 		})
		// 		.catch((err) => {
		// 			setLastError(err.message);
		// 		});
		// }
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
