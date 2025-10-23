<?php

/**
 * Copyright 2025 /tg/station 13
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
 * documentation files (the "Software"), to deal in the Software without restriction, including without limitation the
 * rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all copies or substantial portions of the
 * Software. THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT
 * LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
 * CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

namespace WSOAuth\AuthenticationProvider;

use League\OAuth2\Client\Provider\GenericProvider;
use MediaWiki\User\UserIdentity;

class TgForumAuthProvider extends AuthProvider {

	/**
	 * @var GenericProvider
	 */
	private $provider;

    private const HOST = 'https://forums.tgstation13.org/app.php/tgapi';
    private const VERIFIED_GROUP_ID = 11;

	/**
	 * @inheritDoc
	 */
	public function __construct(
		string $clientId,
		string $clientSecret,
		?string $authUri,
		?string $redirectUri,
		array $extensionData = []
	) {
		$this->provider = new GenericProvider( [
			'clientId' => $clientId,
			'clientSecret' => $clientSecret,
			'redirectUri' => $redirectUri,
			'urlAuthorize' => self::HOST . '/oauth/auth',
			'urlAccessToken' => self::HOST . '/oauth/token',
			'urlResourceOwnerDetails' => self::HOST . '/user/me',
			'scopes' => [ 'user.email user.groups' ]
		] );
	}

	/**
	 * @inheritDoc
	 */
	public function login( ?string &$key, ?string &$secret, ?string &$authUrl ): bool {
		$authUrl = $this->provider->getAuthorizationUrl();

		$secret = $this->provider->getState();

		return true;
	}

	/**
	 * @inheritDoc
	 */
	public function logout( UserIdentity &$user ): void {
	}

	/**
	 * @inheritDoc
	 */
	public function getUser( string $key, string $secret, &$errorMessage ) {
		if ( !isset( $_GET['code'] ) ) {
			return false;
		}

		if ( !isset( $_GET['state'] ) || empty( $_GET['state'] ) || ( $_GET['state'] !== $secret ) ) {
			return false;
		}

		try {
			$token = $this->provider->getAccessToken( 'authorization_code', [ 'code' => $_GET['code'] ] );
            $user = $this->provider->getResourceOwner( $token )->toArray();

			$is_byond_user = false;

			foreach ( $user['groups'] as $forum_group ) {
				if ( $forum_group['group_id'] === self::VERIFIED_GROUP_ID ) {
					$is_byond_user = true;
				}
			}

			if ( !$is_byond_user ) {
				$errorMessage = "Please link your BYOND account with your forum account first.";
				return false;
			}

			return [
				'name' => $user['username'],
                'email' => $user['email']
			];
		} catch ( \Exception $e ) {
			throw $e;
		}
	}

	/**
	 * @inheritDoc
	 */
	public function saveExtraAttributes( int $id ): void {
	}
}