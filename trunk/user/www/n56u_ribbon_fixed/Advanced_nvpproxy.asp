<!DOCTYPE html>
<html>

<head>
	<title>
		<#Web_Title#> - nvpproxy
	</title>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
	<meta http-equiv="Pragma" content="no-cache">
	<meta http-equiv="Expires" content="-1">

	<link rel="shortcut icon" href="images/favicon.ico">
	<link rel="icon" href="images/favicon.png">
	<link rel="stylesheet" type="text/css" href="/bootstrap/css/bootstrap.min.css">
	<link rel="stylesheet" type="text/css" href="/bootstrap/css/main.css">
	<link rel="stylesheet" type="text/css" href="/bootstrap/css/engage.itoggle.css">

	<script type="text/javascript" src="/jquery.js"></script>
	<script type="text/javascript" src="/bootstrap/js/bootstrap.min.js"></script>
	<script type="text/javascript" src="/bootstrap/js/engage.itoggle.min.js"></script>
	<script type="text/javascript" src="/state.js"></script>
	<script type="text/javascript" src="/general.js"></script>
	<script type="text/javascript" src="/itoggle.js"></script>
	<script type="text/javascript" src="/popup.js"></script>
	<script type="text/javascript" src="/help.js"></script>
	<script>
		var $j = jQuery.noConflict();
		$j(document).ready(function () {
			init_itoggle('nvpproxy_enable', change_nvpproxy_enable_bridge);
		});

		function initial() {
			show_banner(2);
			show_menu(5, 21);
			show_footer();

			change_nvpproxy_enable_bridge(1);
		}

		function applyRule() {
			showLoading();

			document.form.action_mode.value = " Apply ";
			document.form.current_page.value = "/Advanced_nvpproxy.asp";
			document.form.next_page.value = "";

			document.form.submit();
		}

		function change_nvpproxy_enable_bridge(mflag) {
			var m = document.form.nvpproxy_enable[0].checked;
			showhide_div("nvpproxy_wan_port_tr", m);
			showhide_div("nvpproxy_vpn_port_tr", m);
		}

		function done_validating(action) {
			refreshpage();
		}

	</script>
</head>

<body onload="initial();" onunLoad="return unload_body();">

	<div class="wrapper">
		<div class="container-fluid" style="padding-right: 0px">
			<div class="row-fluid">
				<div class="span3">
					<center>
						<div id="logo"></div>
					</center>
				</div>
				<div class="span9">
					<div id="TopBanner"></div>
				</div>
			</div>
		</div>

		<div id="Loading" class="popup_bg"></div>

		<iframe name="hidden_frame" id="hidden_frame" src="" width="0" height="0" frameborder="0"></iframe>

		<form method="post" name="form" id="ruleForm" action="/start_apply.htm" target="hidden_frame">

			<input type="hidden" name="current_page" value="Advanced_nvpproxy.asp">
			<input type="hidden" name="next_page" value="">
			<input type="hidden" name="next_host" value="">
			<input type="hidden" name="sid_list" value="NvpproxyConf;">
			<input type="hidden" name="group_id" value="">
			<input type="hidden" name="action_mode" value="">
			<input type="hidden" name="action_script" value="">
			<input type="hidden" name="wan_ipaddr" value="<% nvram_get_x("", " wan0_ipaddr"); %>" readonly="1">
			<input type="hidden" name="wan_netmask" value="<% nvram_get_x("", " wan0_netmask"); %>" readonly="1">
			<input type="hidden" name="dhcp_start" value="<% nvram_get_x("", " dhcp_start"); %>">
			<input type="hidden" name="dhcp_end" value="<% nvram_get_x("", " dhcp_end"); %>">

			<div class="container-fluid">
				<div class="row-fluid">
					<div class="span3">
						<!--Sidebar content-->
						<!--=====Beginning of Main Menu=====-->
						<div class="well sidebar-nav side_nav" style="padding: 0px;">
							<ul id="mainMenu" class="clearfix"></ul>
							<ul class="clearfix">
								<li>
									<div id="subMenu" class="accordion"></div>
								</li>
							</ul>
						</div>
					</div>

					<div class="span9">
						<!--Body content-->
						<div class="row-fluid">
							<div class="span12">
								<div class="box well grad_colour_dark_blue">
									<h2 class="box_head round_top">nvpproxy - 搭建免流</h2>
									<div class="round_bottom">
										<div class="row-fluid">
											<div id="tabMenu" class="submenuBlock"></div>
											<table width="100%" align="center" cellpadding="4" cellspacing="0"
												class="table">
												<tr>
													<th width="30%"><a class="help_tooltip" href="javascript: void(0)"
															onmouseover="openTooltip(this, 26, 9);">启用nvpproxy</a></th>
													<td>
														<div class="main_itoggle">
															<div id="nvpproxy_enable_on_of">
																<input type="checkbox" id="nvpproxy_enable_fake" <%
																	nvram_match_x("", "nvpproxy_enable" , "1"
																	, "value=1 checked" ); %>
																<% nvram_match_x("", "nvpproxy_enable" , "0" , "value=0" );
																	%> />
															</div>
														</div>
														<div style="position: absolute; margin-left: -10000px;">
															<input type="radio" value="1" name="nvpproxy_enable"
																id="nvpproxy_enable_1" class="input" value="1" <%
																nvram_match_x("", "nvpproxy_enable" , "1" , "checked" ); %>
															/><#checkbox_Yes#>
																<input type="radio" value="0" name="nvpproxy_enable"
																	id="nvpproxy_enable_0" class="input" value="0" <%
																	nvram_match_x("", "nvpproxy_enable" , "0" , "checked" );
																	%> /><#checkbox_No#>
														</div>
													</td>
												</tr>
												<tr id="nvpproxy_wan_port_tr" style="display:none;">
													<th width="30%" style="border-top: 0 none;">WAN Port :</th>
													<td style="border-top: 0 none;">
														<input type="text" maxlength="5" class="input" size="15"
															id="nvpproxy_wan_port" name="nvpproxy_wan_port"
															placeholder="600" value="<% nvram_get_x("","
															nvpproxy_wan_port"); %>" onkeypress="return
														is_number(this,event);" />
													</td>
												</tr>
												<tr id="nvpproxy_vpn_port_tr" style="display:none;">
													<th width="30%" style="border-top: 0 none;">VPN Port :</th>
													<td style="border-top: 0 none;">
														<input type="text" maxlength="5" class="input" size="15"
															id="nvpproxy_vpn_port" name="nvpproxy_vpn_port" placeholder="600"
															value="<% nvram_get_x(""," nvpproxy_vpn_port"); %>"
														onkeypress="return is_number(this,event);" />
													</td>
												</tr>
												<tr>
													<td colspan="2" style="border-top: 0 none;">
														<br />
														<center><input class="btn btn-primary" style="width: 219px"
																type="button" value="<#CTL_apply#>"
																onclick="applyRule()" /></center>
													</td>
												</tr>
											</table>
										</div>
									</div>
								</div>
							</div>
						</div>
					</div>
				</div>
			</div>

		</form>

		<div id="footer"></div>
	</div>
</body>

</html>