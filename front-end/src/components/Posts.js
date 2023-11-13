import React, { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import Nav from "./PostsNav";
import Notification from "./Notification";

const Posts = () => {
    const [title, setTitle] = useState("");
    const [description, setDescription] = useState("");
    const [notify, setNotify] = useState(false);
    const [message, setMessage] = useState("");
    const navigate = useNavigate();

    useEffect(() => {
        const checkUser = () => {
            if (!localStorage.getItem("_id")) {
                navigate("/");
            }
        };
        checkUser();
    }, [navigate]);

    const createPost = () => {
        fetch("http://localhost:4000/api/users/" + localStorage.getItem("_id") + "/posts", {
            method: "POST",
            body: JSON.stringify({
                title,
                description,
                "timestamp": new Date().toISOString(),
            }),
            headers: {
                "Content-Type": "application/json",
            },
        })
            .then((res) => {
                if (res.status === 201) {
                    return res.json();
                }
                throw new Error("Something went wrong", res.json());
            })
            .then((data) => {
                setNotify(true);
                setMessage(data.message);
            })
            .catch((err) => console.error(err));
    };
    const handleSubmit = (e) => {
        e.preventDefault();
        createPost();
        setTitle("");
        setDescription("");
    };
    const handleNotification = () => {
        setNotify(false);
        setMessage("");
        navigate("/dashboard");
    }
    return (
        <div>
            <Nav logoPath="images/bal.svg" />
            {notify && <Notification message={message} handle={handleNotification} />}
            <div className='home'>
                <h2 className='homeTitle'>Create a Post</h2>
                <form className='homeForm' onSubmit={handleSubmit}>
                    <div className='home__container'>
                        <label htmlFor='title'>Title</label>
                        <input
                            type='text'
                            name='title'
                            required
                            value={title}
                            onChange={(e) => setTitle(e.target.value)}
                        />
                        <label htmlFor='description'>Description</label>
                        <textarea
                            rows={5}
                            value={description}
                            onChange={(e) => setDescription(e.target.value)}
                            name='description'
                            required
                            className='modalInput'
                        />
                    </div>
                    <button className='homeBtn'>POST</button>
                </form>
            </div>
        </div>
    );
};

export default Posts;
