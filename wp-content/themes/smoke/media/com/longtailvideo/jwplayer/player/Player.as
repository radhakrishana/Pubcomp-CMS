﻿package com.longtailvideo.jwplayer.player {
	import com.longtailvideo.jwplayer.controller.Controller;
	import com.longtailvideo.jwplayer.events.PlayerEvent;
	import com.longtailvideo.jwplayer.model.IPlaylist;
	import com.longtailvideo.jwplayer.model.Model;
	import com.longtailvideo.jwplayer.model.PlayerConfig;
	import com.longtailvideo.jwplayer.plugins.IPlugin;
	import com.longtailvideo.jwplayer.utils.Logger;
	import com.longtailvideo.jwplayer.utils.RootReference;
	import com.longtailvideo.jwplayer.view.IPlayerComponents;
	import com.longtailvideo.jwplayer.view.View;
	import com.longtailvideo.jwplayer.view.interfaces.IPlayerComponent;
	import com.longtailvideo.jwplayer.view.interfaces.ISkin;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	
	
	/**
	 * Sent when the player has been initialized and skins and plugins have been successfully loaded.
	 *
	 * @eventType com.longtailvideo.jwplayer.events.PlayerEvent.JWPLAYER_READY
	 */
	[Event(name="jwplayerReady", type="com.longtailvideo.jwplayer.events.PlayerEvent")]
	/**
	 * Main class for JW Flash Media Player
	 *
	 * @author Pablo Schklowsky
	 */
	public class Player extends Sprite implements IPlayer {
		protected var model:Model;
		protected var view:View;
		protected var controller:Controller;
		
		/** Player constructor **/
		public function Player() {
			try {
				this.addEventListener(Event.ADDED_TO_STAGE, setupPlayer);
			} catch (err:Error) {
				setupPlayer();
			}
		}
		
		
		protected function setupPlayer(event:Event=null):void {
			try {
				this.removeEventListener(Event.ADDED_TO_STAGE, setupPlayer);
			} catch (err:Error) {
			}
			new RootReference(this);
			model = newModel();
			view = newView(model);
			controller = newController(model, view);
			controller.addEventListener(PlayerEvent.JWPLAYER_READY, playerReady, false, -1);
			controller.setupPlayer();
		}
		
		protected function newModel():Model {
			return new Model();
		}
		
		protected function newView(mod:Model):View {
			return new View(this, mod);
		}
		
		protected function newController(mod:Model, vw:View):Controller {
			return new Controller(this, mod, vw);
		} 
		
		protected function playerReady(evt:PlayerEvent):void {
			// Only handle JWPLAYER_READY once
			controller.removeEventListener(PlayerEvent.JWPLAYER_READY, playerReady);
			var jsAPI:JavascriptAPI = new JavascriptAPI(this);
			model.addGlobalListener(forward);
			view.addGlobalListener(forward);
			controller.addGlobalListener(forward);
			forward(evt);
		}
		
		
		/**
		 * Forwards all MVC events to interested listeners.
		 * @param evt
		 */
		protected function forward(evt:PlayerEvent):void {
			Logger.log(evt.toString(), evt.type);
			dispatchEvent(evt);
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function get config():PlayerConfig {
			return model.config;
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function get version():String {
			return PlayerVersion.version;
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function get skin():ISkin {
			return view.skin;
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function get state():String {
			return model.state;
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function get playlist():IPlaylist {
			return model.playlist;
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function get locked():Boolean {
			return controller.locking;
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function lock(target:IPlugin, callback:Function):void {
			controller.lockPlayback(target, callback);
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function unlock(target:IPlugin):Boolean {
			return controller.unlockPlayback(target);
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function volume(volume:Number):Boolean {
			return controller.setVolume(volume);
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function get mute():Boolean {
			return model.mute;
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function set mute(state:Boolean):void {
			controller.mute(state);
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function play():Boolean {
			return controller.play();
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function pause():Boolean {
			return controller.pause();
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function stop():Boolean {
			return controller.stop();
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function seek(position:Number):Boolean {
			return controller.seek(position);
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function load(item:*):Boolean {
			return controller.load(item);
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function playlistItem(index:Number):Boolean {
			return controller.setPlaylistIndex(index);
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function playlistNext():Boolean {
			return controller.next();
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function playlistPrev():Boolean {
			return controller.previous();
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function redraw():Boolean {
			return controller.redraw();
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function get fullscreen():Boolean {
			return model.fullscreen;
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function set fullscreen(on:Boolean):void {
			controller.fullscreen(on);
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function link(index:Number = NaN):Boolean {
			return controller.link(index);
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function get controls():IPlayerComponents {
			return view.components;
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function overrideComponent(plugin:IPlayerComponent):void {
			view.overrideComponent(plugin);
		}
		
		/** 
		 * @private
		 * 
		 * This method is deprecated, and is used for backwards compatibility only.
		 */
		public function getPlugin(id:String):Object {
			return view.getPlugin(id);
		} 
		
		/** The player should not accept any calls referencing its display stack **/
		public override function addChild(child:DisplayObject):DisplayObject {
			return null;
		}

		/** The player should not accept any calls referencing its display stack **/
		public override function addChildAt(child:DisplayObject, index:int):DisplayObject {
			return null;
		}

		/** The player should not accept any calls referencing its display stack **/
		public override function removeChild(child:DisplayObject):DisplayObject {
			return null;
		}

		/** The player should not accept any calls referencing its display stack **/
		public override function removeChildAt(index:int):DisplayObject {
			return null;
		}
		
	}
}