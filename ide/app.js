"use strict";
const electron = require("electron");
const appConfig = require("electron-settings");
const path = require("path");const fs = require("fs");
const app = electron.app;
const pathtoElectron = process.platform.match(/win/)?path.resolve(process.env.APPDATA, "npm/electron.cmd"):null;

if (process.env.NODE_ENV!=="prod") {
	require("electron-reload")(__dirname, {
		electron: pathtoElectron,
		hardResetMethod: "exit"
	});
	require("electron-debug")({
		devToolsMode: "previous"
	});
}

let mainWindow;
function onClosed() {
	mainWindow = null;
}

function createMainWindow() {
	const mainWindowStateKeeper = windowStateKeeper("main");
	const win = new electron.BrowserWindow({
		title: "main",
		x: mainWindowStateKeeper.x || 10,
		y: mainWindowStateKeeper.y || 10,
		width: mainWindowStateKeeper.width || 1200,
		height: mainWindowStateKeeper.height || 1000,
		webPreferences: {
			preload: path.join(app.getAppPath(), "preload.js"),
			contextIsolation: false,
			enableRemoteModule: true,
			allowEval: false
		}
	});
	mainWindowStateKeeper.track(win);

	win.loadURL(`file://${__dirname}/index.html`);
	win.on("closed", onClosed);

	return win;
}

app.on("window-all-closed", () => {
	if (process.platform !== "darwin") {
		app.quit();
	}
});

app.on("activate", () => {
	if (!mainWindow) {
		mainWindow = createMainWindow();
	}
});

app.on("ready", () => {
	mainWindow = createMainWindow();
});


function windowStateKeeper(windowName) {
	let window, windowState;
	function setBounds() {
	// Restore from appConfig
	if (appConfig.has(`windowState.${windowName}`)) {
		windowState = appConfig.get(`windowState.${windowName}`);
		return;
	}
	// Default
	windowState = {
		x: undefined,
		y: undefined,
		width: 1000,
		height: 800,
	};
	}
	function saveState() {
		if (!windowState.isMaximized) windowState = window.getBounds();
		windowState.isMaximized = window.isMaximized();
		appConfig.set(`windowState.${windowName}`, windowState);
	}
	function track(win) {
		window = win;
		["resize", "move", "close"].forEach(event => win.on(event, saveState));
	}
	setBounds();
	return({
		x: windowState.x,
		y: windowState.y,
		width: windowState.width,
		height: windowState.height,
		isMaximized: windowState.isMaximized,
		track
	});
}