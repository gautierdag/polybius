��
l��F� j�P.�M�.�}q (X   protocol_versionqM�X   little_endianq�X
   type_sizesq}q(X   shortqKX   intqKX   longqKuu.�(X   moduleq cmodels.shapes_cnn
ShapesCNN
qX?   /home/lgpu0444/diagnostics-shapes/baseline/models/shapes_cnn.pyqX{  class ShapesCNN(nn.Module):
    def __init__(self, n_out_features):
        super().__init__()

        n_filters = 20

        self.conv_net = nn.Sequential(
            nn.Conv2d(3, n_filters, 3, stride=2),
            nn.BatchNorm2d(n_filters),
            nn.ReLU(),
            nn.Conv2d(n_filters, n_filters, 3, stride=2),
            nn.BatchNorm2d(n_filters),
            nn.ReLU(),
            nn.Conv2d(n_filters, n_filters, 3, stride=2),
            nn.BatchNorm2d(n_filters),
            nn.ReLU()
        )
        self.lin = nn.Sequential(nn.Linear(80, n_out_features), nn.ReLU())

        self._init_params()

    def _init_params(self):
        for m in self.modules():
            if isinstance(m, nn.Conv2d):
                nn.init.kaiming_normal_(m.weight, mode="fan_out", nonlinearity="relu")
            elif isinstance(m, nn.BatchNorm2d):
                nn.init.constant_(m.weight, 1)
                nn.init.constant_(m.bias, 0)

    def forward(self, x):
        batch_size = x.size(0)
        output = self.conv_net(x)
        output = output.view(batch_size, -1)
        output = self.lin(output)
        return output
qtqQ)�q}q(X   _backendqctorch.nn.backends.thnn
_get_thnn_function_backend
q)Rq	X   _parametersq
ccollections
OrderedDict
q)RqX   _buffersqh)RqX   _backward_hooksqh)RqX   _forward_hooksqh)RqX   _forward_pre_hooksqh)RqX   _state_dict_hooksqh)RqX   _load_state_dict_pre_hooksqh)RqX   _modulesqh)Rq(X   conv_netq(h ctorch.nn.modules.container
Sequential
qXO   /home/lgpu0444/.local/lib/python3.6/site-packages/torch/nn/modules/container.pyqX�	  class Sequential(Module):
    r"""A sequential container.
    Modules will be added to it in the order they are passed in the constructor.
    Alternatively, an ordered dict of modules can also be passed in.

    To make it easier to understand, here is a small example::

        # Example of using Sequential
        model = nn.Sequential(
                  nn.Conv2d(1,20,5),
                  nn.ReLU(),
                  nn.Conv2d(20,64,5),
                  nn.ReLU()
                )

        # Example of using Sequential with OrderedDict
        model = nn.Sequential(OrderedDict([
                  ('conv1', nn.Conv2d(1,20,5)),
                  ('relu1', nn.ReLU()),
                  ('conv2', nn.Conv2d(20,64,5)),
                  ('relu2', nn.ReLU())
                ]))
    """

    def __init__(self, *args):
        super(Sequential, self).__init__()
        if len(args) == 1 and isinstance(args[0], OrderedDict):
            for key, module in args[0].items():
                self.add_module(key, module)
        else:
            for idx, module in enumerate(args):
                self.add_module(str(idx), module)

    def _get_item_by_idx(self, iterator, idx):
        """Get the idx-th item of the iterator"""
        size = len(self)
        idx = operator.index(idx)
        if not -size <= idx < size:
            raise IndexError('index {} is out of range'.format(idx))
        idx %= size
        return next(islice(iterator, idx, None))

    def __getitem__(self, idx):
        if isinstance(idx, slice):
            return self.__class__(OrderedDict(list(self._modules.items())[idx]))
        else:
            return self._get_item_by_idx(self._modules.values(), idx)

    def __setitem__(self, idx, module):
        key = self._get_item_by_idx(self._modules.keys(), idx)
        return setattr(self, key, module)

    def __delitem__(self, idx):
        if isinstance(idx, slice):
            for key in list(self._modules.keys())[idx]:
                delattr(self, key)
        else:
            key = self._get_item_by_idx(self._modules.keys(), idx)
            delattr(self, key)

    def __len__(self):
        return len(self._modules)

    def __dir__(self):
        keys = super(Sequential, self).__dir__()
        keys = [key for key in keys if not key.isdigit()]
        return keys

    def forward(self, input):
        for module in self._modules.values():
            input = module(input)
        return input
qtqQ)�q }q!(hh	h
h)Rq"hh)Rq#hh)Rq$hh)Rq%hh)Rq&hh)Rq'hh)Rq(hh)Rq)(X   0q*(h ctorch.nn.modules.conv
Conv2d
q+XJ   /home/lgpu0444/.local/lib/python3.6/site-packages/torch/nn/modules/conv.pyq,X!  class Conv2d(_ConvNd):
    r"""Applies a 2D convolution over an input signal composed of several input
    planes.

    In the simplest case, the output value of the layer with input size
    :math:`(N, C_{\text{in}}, H, W)` and output :math:`(N, C_{\text{out}}, H_{\text{out}}, W_{\text{out}})`
    can be precisely described as:

    .. math::
        \text{out}(N_i, C_{\text{out}_j}) = \text{bias}(C_{\text{out}_j}) +
        \sum_{k = 0}^{C_{\text{in}} - 1} \text{weight}(C_{\text{out}_j}, k) \star \text{input}(N_i, k)


    where :math:`\star` is the valid 2D `cross-correlation`_ operator,
    :math:`N` is a batch size, :math:`C` denotes a number of channels,
    :math:`H` is a height of input planes in pixels, and :math:`W` is
    width in pixels.

    * :attr:`stride` controls the stride for the cross-correlation, a single
      number or a tuple.

    * :attr:`padding` controls the amount of implicit zero-paddings on both
      sides for :attr:`padding` number of points for each dimension.

    * :attr:`dilation` controls the spacing between the kernel points; also
      known as the à trous algorithm. It is harder to describe, but this `link`_
      has a nice visualization of what :attr:`dilation` does.

    * :attr:`groups` controls the connections between inputs and outputs.
      :attr:`in_channels` and :attr:`out_channels` must both be divisible by
      :attr:`groups`. For example,

        * At groups=1, all inputs are convolved to all outputs.
        * At groups=2, the operation becomes equivalent to having two conv
          layers side by side, each seeing half the input channels,
          and producing half the output channels, and both subsequently
          concatenated.
        * At groups= :attr:`in_channels`, each input channel is convolved with
          its own set of filters, of size:
          :math:`\left\lfloor\frac{C_\text{out}}{C_\text{in}}\right\rfloor`.

    The parameters :attr:`kernel_size`, :attr:`stride`, :attr:`padding`, :attr:`dilation` can either be:

        - a single ``int`` -- in which case the same value is used for the height and width dimension
        - a ``tuple`` of two ints -- in which case, the first `int` is used for the height dimension,
          and the second `int` for the width dimension

    .. note::

         Depending of the size of your kernel, several (of the last)
         columns of the input might be lost, because it is a valid `cross-correlation`_,
         and not a full `cross-correlation`_.
         It is up to the user to add proper padding.

    .. note::

        When `groups == in_channels` and `out_channels == K * in_channels`,
        where `K` is a positive integer, this operation is also termed in
        literature as depthwise convolution.

        In other words, for an input of size :math:`(N, C_{in}, H_{in}, W_{in})`,
        a depthwise convolution with a depthwise multiplier `K`, can be constructed by arguments
        :math:`(in\_channels=C_{in}, out\_channels=C_{in} \times K, ..., groups=C_{in})`.

    .. include:: cudnn_deterministic.rst

    Args:
        in_channels (int): Number of channels in the input image
        out_channels (int): Number of channels produced by the convolution
        kernel_size (int or tuple): Size of the convolving kernel
        stride (int or tuple, optional): Stride of the convolution. Default: 1
        padding (int or tuple, optional): Zero-padding added to both sides of the input. Default: 0
        dilation (int or tuple, optional): Spacing between kernel elements. Default: 1
        groups (int, optional): Number of blocked connections from input channels to output channels. Default: 1
        bias (bool, optional): If ``True``, adds a learnable bias to the output. Default: ``True``

    Shape:
        - Input: :math:`(N, C_{in}, H_{in}, W_{in})`
        - Output: :math:`(N, C_{out}, H_{out}, W_{out})` where

          .. math::
              H_{out} = \left\lfloor\frac{H_{in}  + 2 \times \text{padding}[0] - \text{dilation}[0]
                        \times (\text{kernel\_size}[0] - 1) - 1}{\text{stride}[0]} + 1\right\rfloor

          .. math::
              W_{out} = \left\lfloor\frac{W_{in}  + 2 \times \text{padding}[1] - \text{dilation}[1]
                        \times (\text{kernel\_size}[1] - 1) - 1}{\text{stride}[1]} + 1\right\rfloor

    Attributes:
        weight (Tensor): the learnable weights of the module of shape
                         (out_channels, in_channels, kernel_size[0], kernel_size[1]).
                         The values of these weights are sampled from
                         :math:`\mathcal{U}(-\sqrt{k}, \sqrt{k})` where
                         :math:`k = \frac{1}{C_\text{in} * \prod_{i=0}^{1}\text{kernel\_size}[i]}`
        bias (Tensor):   the learnable bias of the module of shape (out_channels). If :attr:`bias` is ``True``,
                         then the values of these weights are
                         sampled from :math:`\mathcal{U}(-\sqrt{k}, \sqrt{k})` where
                         :math:`k = \frac{1}{C_\text{in} * \prod_{i=0}^{1}\text{kernel\_size}[i]}`

    Examples::

        >>> # With square kernels and equal stride
        >>> m = nn.Conv2d(16, 33, 3, stride=2)
        >>> # non-square kernels and unequal stride and with padding
        >>> m = nn.Conv2d(16, 33, (3, 5), stride=(2, 1), padding=(4, 2))
        >>> # non-square kernels and unequal stride and with padding and dilation
        >>> m = nn.Conv2d(16, 33, (3, 5), stride=(2, 1), padding=(4, 2), dilation=(3, 1))
        >>> input = torch.randn(20, 16, 50, 100)
        >>> output = m(input)

    .. _cross-correlation:
        https://en.wikipedia.org/wiki/Cross-correlation

    .. _link:
        https://github.com/vdumoulin/conv_arithmetic/blob/master/README.md
    """
    def __init__(self, in_channels, out_channels, kernel_size, stride=1,
                 padding=0, dilation=1, groups=1, bias=True):
        kernel_size = _pair(kernel_size)
        stride = _pair(stride)
        padding = _pair(padding)
        dilation = _pair(dilation)
        super(Conv2d, self).__init__(
            in_channels, out_channels, kernel_size, stride, padding, dilation,
            False, _pair(0), groups, bias)

    @weak_script_method
    def forward(self, input):
        return F.conv2d(input, self.weight, self.bias, self.stride,
                        self.padding, self.dilation, self.groups)
q-tq.Q)�q/}q0(hh	h
h)Rq1(X   weightq2ctorch._utils
_rebuild_parameter
q3ctorch._utils
_rebuild_tensor_v2
q4((X   storageq5ctorch
FloatStorage
q6X   53929152q7X   cuda:0q8MNtq9QK (KKKKtq:(KK	KKtq;�h)Rq<tq=Rq>�h)Rq?�q@RqAX   biasqBh3h4((h5h6X   53748576qCX   cuda:0qDKNtqEQK K�qFK�qG�h)RqHtqIRqJ�h)RqK�qLRqMuhh)RqNhh)RqOhh)RqPhh)RqQhh)RqRhh)RqShh)RqTX   trainingqU�X   in_channelsqVKX   out_channelsqWKX   kernel_sizeqXKK�qYX   strideqZKK�q[X   paddingq\K K �q]X   dilationq^KK�q_X
   transposedq`�X   output_paddingqaK K �qbX   groupsqcKubX   1qd(h ctorch.nn.modules.batchnorm
BatchNorm2d
qeXO   /home/lgpu0444/.local/lib/python3.6/site-packages/torch/nn/modules/batchnorm.pyqfX#  class BatchNorm2d(_BatchNorm):
    r"""Applies Batch Normalization over a 4D input (a mini-batch of 2D inputs
    with additional channel dimension) as described in the paper
    `Batch Normalization: Accelerating Deep Network Training by Reducing Internal Covariate Shift`_ .

    .. math::

        y = \frac{x - \mathrm{E}[x]}{ \sqrt{\mathrm{Var}[x] + \epsilon}} * \gamma + \beta

    The mean and standard-deviation are calculated per-dimension over
    the mini-batches and :math:`\gamma` and :math:`\beta` are learnable parameter vectors
    of size `C` (where `C` is the input size). By default, the elements of :math:`\gamma` are sampled
    from :math:`\mathcal{U}(0, 1)` and the elements of :math:`\beta` are set to 0.

    Also by default, during training this layer keeps running estimates of its
    computed mean and variance, which are then used for normalization during
    evaluation. The running estimates are kept with a default :attr:`momentum`
    of 0.1.

    If :attr:`track_running_stats` is set to ``False``, this layer then does not
    keep running estimates, and batch statistics are instead used during
    evaluation time as well.

    .. note::
        This :attr:`momentum` argument is different from one used in optimizer
        classes and the conventional notion of momentum. Mathematically, the
        update rule for running statistics here is
        :math:`\hat{x}_\text{new} = (1 - \text{momentum}) \times \hat{x} + \text{momemtum} \times x_t`,
        where :math:`\hat{x}` is the estimated statistic and :math:`x_t` is the
        new observed value.

    Because the Batch Normalization is done over the `C` dimension, computing statistics
    on `(N, H, W)` slices, it's common terminology to call this Spatial Batch Normalization.

    Args:
        num_features: :math:`C` from an expected input of size
            :math:`(N, C, H, W)`
        eps: a value added to the denominator for numerical stability.
            Default: 1e-5
        momentum: the value used for the running_mean and running_var
            computation. Can be set to ``None`` for cumulative moving average
            (i.e. simple average). Default: 0.1
        affine: a boolean value that when set to ``True``, this module has
            learnable affine parameters. Default: ``True``
        track_running_stats: a boolean value that when set to ``True``, this
            module tracks the running mean and variance, and when set to ``False``,
            this module does not track such statistics and always uses batch
            statistics in both training and eval modes. Default: ``True``

    Shape:
        - Input: :math:`(N, C, H, W)`
        - Output: :math:`(N, C, H, W)` (same shape as input)

    Examples::

        >>> # With Learnable Parameters
        >>> m = nn.BatchNorm2d(100)
        >>> # Without Learnable Parameters
        >>> m = nn.BatchNorm2d(100, affine=False)
        >>> input = torch.randn(20, 100, 35, 45)
        >>> output = m(input)

    .. _`Batch Normalization: Accelerating Deep Network Training by Reducing Internal Covariate Shift`:
        https://arxiv.org/abs/1502.03167
    """

    @weak_script_method
    def _check_input_dim(self, input):
        if input.dim() != 4:
            raise ValueError('expected 4D input (got {}D input)'
                             .format(input.dim()))
qgtqhQ)�qi}qj(hh	h
h)Rqk(h2h3h4((h5h6X   53976992qlX   cuda:0qmKNtqnQK K�qoK�qp�h)RqqtqrRqs�h)Rqt�quRqvhBh3h4((h5h6X   53977088qwX   cuda:0qxKNtqyQK K�qzK�q{�h)Rq|tq}Rq~�h)Rq�q�Rq�uhh)Rq�(X   running_meanq�h4((h5h6X   54081232q�X   cuda:0q�KNtq�QK K�q�K�q��h)Rq�tq�Rq�X   running_varq�h4((h5h6X   54174112q�X   cuda:0q�KNtq�QK K�q�K�q��h)Rq�tq�Rq�X   num_batches_trackedq�h4((h5ctorch
LongStorage
q�X   54229040q�X   cuda:0q�KNtq�QK ))�h)Rq�tq�Rq�uhh)Rq�hh)Rq�hh)Rq�hh)Rq�hh)Rq�hh)Rq�hU�X   num_featuresq�KX   epsq�G>�����h�X   momentumq�G?�������X   affineq��X   track_running_statsq��ubX   2q�(h ctorch.nn.modules.activation
ReLU
q�XP   /home/lgpu0444/.local/lib/python3.6/site-packages/torch/nn/modules/activation.pyq�X�  class ReLU(Threshold):
    r"""Applies the rectified linear unit function element-wise
    :math:`\text{ReLU}(x)= \max(0, x)`

    .. image:: scripts/activation_images/ReLU.png

    Args:
        inplace: can optionally do the operation in-place. Default: ``False``

    Shape:
        - Input: :math:`(N, *)` where `*` means, any number of additional
          dimensions
        - Output: :math:`(N, *)`, same shape as the input

    Examples::

        >>> m = nn.ReLU()
        >>> input = torch.randn(2)
        >>> output = m(input)
    """

    def __init__(self, inplace=False):
        super(ReLU, self).__init__(0., 0., inplace)

    def extra_repr(self):
        inplace_str = 'inplace' if self.inplace else ''
        return inplace_str
q�tq�Q)�q�}q�(hh	h
h)Rq�hh)Rq�hh)Rq�hh)Rq�hh)Rq�hh)Rq�hh)Rq�hh)Rq�hU�X	   thresholdq�G        X   valueq�G        X   inplaceq��ubX   3q�h+)�q�}q�(hh	h
h)Rq�(h2h3h4((h5h6X   54084080q�X   cuda:0q�MNtq�QK (KKKKtq�(K�K	KKtqh)Rq�tq�Rqňh)RqƇq�Rq�hBh3h4((h5h6X   54366496q�X   cuda:0q�KNtq�QK K�q�K�q͉h)Rq�tq�RqЈh)Rqчq�Rq�uhh)Rq�hh)Rq�hh)Rq�hh)Rq�hh)Rq�hh)Rq�hh)Rq�hU�hVKhWKhXKK�q�hZKK�q�h\K K �q�h^KK�q�h`�haK K �q�hcKubX   4q�he)�q�}q�(hh	h
h)Rq�(h2h3h4((h5h6X   54084176q�X   cuda:0q�KNtq�QK K�q�K�q�h)Rq�tq�Rq�h)Rq�q�Rq�hBh3h4((h5h6X   52686352q�X   cuda:0q�KNtq�QK K�q�K�q�h)Rq�tq�Rq��h)Rq��q�Rq�uhh)Rq�(h�h4((h5h6X   52902480q�X   cuda:0q�KNtq�QK K�q�K�q��h)Rr   tr  Rr  h�h4((h5h6X   53895184r  X   cuda:0r  KNtr  QK K�r  K�r  �h)Rr  tr	  Rr
  h�h4((h5h�X   54357712r  X   cuda:0r  KNtr  QK ))�h)Rr  tr  Rr  uhh)Rr  hh)Rr  hh)Rr  hh)Rr  hh)Rr  hh)Rr  hU�h�Kh�G>�����h�h�G?�������h��h��ubX   5r  h�)�r  }r  (hh	h
h)Rr  hh)Rr  hh)Rr  hh)Rr  hh)Rr  hh)Rr  hh)Rr   hh)Rr!  hU�h�G        h�G        h��ubX   6r"  h+)�r#  }r$  (hh	h
h)Rr%  (h2h3h4((h5h6X   54413184r&  X   cuda:0r'  MNtr(  QK (KKKKtr)  (K�K	KKtr*  �h)Rr+  tr,  Rr-  �h)Rr.  �r/  Rr0  hBh3h4((h5h6X   54357808r1  X   cuda:0r2  KNtr3  QK K�r4  K�r5  �h)Rr6  tr7  Rr8  �h)Rr9  �r:  Rr;  uhh)Rr<  hh)Rr=  hh)Rr>  hh)Rr?  hh)Rr@  hh)RrA  hh)RrB  hU�hVKhWKhXKK�rC  hZKK�rD  h\K K �rE  h^KK�rF  h`�haK K �rG  hcKubX   7rH  he)�rI  }rJ  (hh	h
h)RrK  (h2h3h4((h5h6X   52802336rL  X   cuda:0rM  KNtrN  QK K�rO  K�rP  �h)RrQ  trR  RrS  �h)RrT  �rU  RrV  hBh3h4((h5h6X   54600576rW  X   cuda:0rX  KNtrY  QK K�rZ  K�r[  �h)Rr\  tr]  Rr^  �h)Rr_  �r`  Rra  uhh)Rrb  (h�h4((h5h6X   54316224rc  X   cuda:0rd  KNtre  QK K�rf  K�rg  �h)Rrh  tri  Rrj  h�h4((h5h6X   53161360rk  X   cuda:0rl  KNtrm  QK K�rn  K�ro  �h)Rrp  trq  Rrr  h�h4((h5h�X   54166336rs  X   cuda:0rt  KNtru  QK ))�h)Rrv  trw  Rrx  uhh)Rry  hh)Rrz  hh)Rr{  hh)Rr|  hh)Rr}  hh)Rr~  hU�h�Kh�G>�����h�h�G?�������h��h��ubX   8r  h�)�r�  }r�  (hh	h
h)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hU�h�G        h�G        h��ubuhU�ubX   linr�  h)�r�  }r�  (hh	h
h)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  (X   0r�  (h ctorch.nn.modules.linear
Linear
r�  XL   /home/lgpu0444/.local/lib/python3.6/site-packages/torch/nn/modules/linear.pyr�  XQ	  class Linear(Module):
    r"""Applies a linear transformation to the incoming data: :math:`y = xA^T + b`

    Args:
        in_features: size of each input sample
        out_features: size of each output sample
        bias: If set to False, the layer will not learn an additive bias.
            Default: ``True``

    Shape:
        - Input: :math:`(N, *, \text{in\_features})` where :math:`*` means any number of
          additional dimensions
        - Output: :math:`(N, *, \text{out\_features})` where all but the last dimension
          are the same shape as the input.

    Attributes:
        weight: the learnable weights of the module of shape
            :math:`(\text{out\_features}, \text{in\_features})`. The values are
            initialized from :math:`\mathcal{U}(-\sqrt{k}, \sqrt{k})`, where
            :math:`k = \frac{1}{\text{in\_features}}`
        bias:   the learnable bias of the module of shape :math:`(\text{out\_features})`.
                If :attr:`bias` is ``True``, the values are initialized from
                :math:`\mathcal{U}(-\sqrt{k}, \sqrt{k})` where
                :math:`k = \frac{1}{\text{in\_features}}`

    Examples::

        >>> m = nn.Linear(20, 30)
        >>> input = torch.randn(128, 20)
        >>> output = m(input)
        >>> print(output.size())
        torch.Size([128, 30])
    """
    __constants__ = ['bias']

    def __init__(self, in_features, out_features, bias=True):
        super(Linear, self).__init__()
        self.in_features = in_features
        self.out_features = out_features
        self.weight = Parameter(torch.Tensor(out_features, in_features))
        if bias:
            self.bias = Parameter(torch.Tensor(out_features))
        else:
            self.register_parameter('bias', None)
        self.reset_parameters()

    def reset_parameters(self):
        init.kaiming_uniform_(self.weight, a=math.sqrt(5))
        if self.bias is not None:
            fan_in, _ = init._calculate_fan_in_and_fan_out(self.weight)
            bound = 1 / math.sqrt(fan_in)
            init.uniform_(self.bias, -bound, bound)

    @weak_script_method
    def forward(self, input):
        return F.linear(input, self.weight, self.bias)

    def extra_repr(self):
        return 'in_features={}, out_features={}, bias={}'.format(
            self.in_features, self.out_features, self.bias is not None
        )
r�  tr�  Q)�r�  }r�  (hh	h
h)Rr�  (h2h3h4((h5h6X   43677408r�  X   cuda:0r�  M Ntr�  QK K@KP�r�  KPK�r�  �h)Rr�  tr�  Rr�  �h)Rr�  �r�  Rr�  hBh3h4((h5h6X   54166432r�  X   cuda:0r�  K@Ntr�  QK K@�r�  K�r�  �h)Rr�  tr�  Rr�  �h)Rr�  �r�  Rr�  uhh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hU�X   in_featuresr�  KPX   out_featuresr�  K@ubX   1r�  h�)�r�  }r�  (hh	h
h)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hU�h�G        h�G        h��ubuhU�ubuhU�ub.�]q (X   43677408qX   52686352qX   52802336qX   52902480qX   53161360qX   53748576qX   53895184qX   53929152qX   53976992q	X   53977088q
X   54081232qX   54084080qX   54084176qX   54166336qX   54166432qX   54174112qX   54229040qX   54316224qX   54357712qX   54357808qX   54366496qX   54413184qX   54600576qe.       K#L�o2>���=�bE>� ;��7<��1L>�Y{�E�y=i��>˖>ï�X��X������=W�+>l�Q�up����,>m�,<ơ<%7>�gD=�������=g$�>��X=����E�={ͩ<�{�=a�½R�-;��h���F>S��=��->�&��Oc>3g=E�Ά�<%\%>�E=�9�h���\<��C�n"��=��Q>K�=��]=ǅ�BR'>��<��V�3`�>��n=���L�)=I���v���W]>�=�V�= �?<�=D~M<xؖ�|��<躯��Ѹ=G�=� >������<i��>s�v>e��=ES�<�>�F��=~�=����woû�b�=�\�=��;�ܽ�h�s�O=L�]=� Q; y��^l<�:���7�ʽ�ǽ����v2->�����$����=OcA=�1�2:���< �>N���Ï<!a���t�&�=絼
ۚ;GX�=�y��(ll�֩>�>��:���=��<��=z�59�盽Ęf<�{=;���>ON�=꠩=Buk��I2�������<{����	>��!O��<��a<��rԦ<S���^��tƫ�UY=���s�=s��<�W�X\ ��=�3�=�*�I@����:=��=]H�~=��.>�� =�'u��}=��>�<�zF=�T~=��>5�`=����tt>�� �X��=�Gٽ5
8�=��<;��=���=	Z>ꛉ=#�:��H��.5�=�u�=��+��⼤��=��}>�b>�"%���=؛ѽ��<ȓ��#�6=^��=���=] �=V�����=|*={<���Z�=��<K2�Q��=��>&��=�;>l�=�W
��]9=�"�=^��=�V��ν�u����=�.p���S��ӏ=q�ɻ$=���U��<���=��+=�	E��&>�=X&>\��=u<�=��<|/���qL��f$��R,>��=n�c�:�h���=�Ԃ<w=4=�)=��=�ҋ=̴���y��l� =�˽,Ɗ=���ɕ�=�B>n�=)wӼ۫�=�)����=}>�Y|>n(�=jd����=���=�}�;�>Jt�=\�����=��y��{Z=���=;��=2T	>U,k��m�>���j<��L���c���%<]ǿ=!Ȯ�H0½6_��b�#������`>��ؽ����'�:du=���<�8`�Vl=��F=����p�Zт=3�>sC���4�}��=���=��=cHm�O�>.����	�:C�=�b����mO&�F��;=D�=��7���>�bM�q�5=wo�<aM>�X��!�>qѽ>��<����	�=�܇=��=��'����G�>l>M���R�=X�x�!0�=�Cp�ta���x�=o����}��9T>l�=���=C�<��ߠ<�^���ڼWWI=�}�=�>z�w6�����=C��=����ö=�c�U�Ͻ�hA>�2��Q�;�3)>�,���C�=p�5�����^�m=�:>��%���C>����F�0����ed�=☒=�V`�O��=!x4=0�=�E��AJ��3��a'=�<�>P>�-�=v/=ޝ����H=���D=��̽��L�ऌ<��<?�5�>@~��8c����iΟ=%���`ѽƍ�=�c�=�N">��u=۔��I>��1�4TJ�3D�>���3+>UV<k�l�qp;�Uw���3G�� �J��=���<�ͽ)K>m+�:���=2��=�&k=�*��ؘ<�P���11>��<��<0޽
��=f9�=̈́�=��
>�E��w`��0�=]�V�_����=�ȭ��f�=h�<D���E=ɞ�<�*�==������<Pv�=�
�4��=Hb��+�>��=B�=׀ٻx�>Yǫ<ْ_�d�������=�1��>�B�<����c�=��+�EC��b�7=T��f��;TD�=&�>6�=p-����X>^��r'[�ϝc����=¸=��>MS齒��=�|>���=��<�o(>���j��=>%�=7�>M���t�>as=�}�<>��=Q)!�� ,�:$�;���=?=>d��Cg���`�=ԟ=�o+=��>��<O���J�<g�;=ߚ=��>��>��9���<=o���=}�s>�'=v�c�@��<�L >�L���k=���-�=L�� >���s�
���>�8Oؼ�?��Fj =e(��A�=;�y=����^�<�Z����=��=L�O�$�����=,�<1���H�K#8=,��=K-���Y>ӑ=��s=���=�ؿ=	���By�E�5���$>G��V�>���J��<nѡ=c{�������=�@&>���=�e���5>_��_L>Jk�=]@=&^ȽsZ�=�8]��dD���ý��>���E����N���d�ǟ/>���eL߽�W�!	�=M;��z�I>���=�-�V�=b���8�=�˽,���5>��%��+ ��"=	�^�yς=QF�=��(>��^=ͩ��G��<����\=iγ���<��)<+�0���<gr�=�3�Yw�=���=58f�������=��A=��>��L=���=Ϧ��RP=��廪�A>�� =^����ꆽե������ŉ�X��=^8���^`>�>h�������c�=x�z>]�U�2�<1�b/�=�䞽�)>^=����O�.�����)��hς�����q>-	>��=H@>=�=���W; <�=�lɽ��F=��)>��6=�μ�r>��<n=����_�t<E�=�d=0���@$���>�2�(ҽt�G��Z=C%>�/˽$��=,Q,�B!�gT�;��=a�=T��G�F=m�*��
=�8m��}w�b��=�-s�v����+��FH>�Ǽ��{�=��=�)>�G�<��&>�?=@��=/��=%�����='�M<��g�� ��:\<|T>M�<�.	=������=�`G�w��;*%B�՞!=��C��[l��eB���>�N)�_�����>�7�
q���WM���C��/4�&;[����=���</��=%0;�콌X>���<�k�� :>^��h'�>y�W���n=4B�=7�>�>U.�=�5	>b�3>�'�7�w=a�=�v��B=YWk<G>=��G��=7�r�VO�=��M�=J'�<��=��X>�h=�Z=~��=��=�l�Ǳ�=���=�v�>Q�B=��:���=k!�=[�@�����V����$<�<�?���d�<�Ƚa�=���B���.����:�\�&�EiG=������E��53>�����ͮ�j[ƽ�[ֽ�l�@X8=�)��_n=c'>WA=��˽��l��{�=Ϡw��'���1������'?�������=>����-�����=Qx)=62>�0{��{��m��=��=S�����=�'����Q>�/>NC=t��=�'>Z���f�<f�->N-Q�r2�=Rr=X �=����ެ�|��=�i����<>Ws.��e���9>�'�=�����ݘ��.�K=�Q�ٯG>�9m�zF*>��A�;^�H<Aݥ�ۻc���j=���no��*�<l0=�� ���O�9m"�='C����<���=�p>���<ڊ�:�0�VQ=�'��P�3>�!ʽ2���7�;Db��,=��z��ՠ=u�<�-V>��코S�3���=�Źr��z��<_۬�A�1�Aꓽ�B=�'>DK���t�=�"9���=��=��>7�=�1U���<!;����1o���K;-Hk�˵;���=1�6=��ࡉ�ǥ�7G��|�=�Ы�F�=��|�ř1=�����=��Ž�ԃ=�~�=��z��D�=;��;S�w���=\���E�H���<'�;)W���c��kF��,؞=yԣ=�����H˼L��=���/'��= ��60��Pf;�>Y[l=��)>۝�� �����;��޽�����S2�Q/�=T_L>7�Z<+����<�ˋ�F�z�%��g!�
������/� =vG>l����ʽ�Y��m���o�.Ѽ&N>�-=�4�����<G�=��H�U������o*�ǧ���	ͺ���=����OX���ᮽ;I齲�轭��=o��g�m��~��dF=����b����<���<���<Tp���l0=j�J=d����<�����6=tҽr�<�Ƚ3�=z�c=�Q�<�淽j>�̩��!�=��85>���<��i>��:=m>�=J��4q=�込N��=��vi��U�k�޼��2=p��=���c!�=2�c��%�=+]=�ܼ�_w��R�=�i�������ȼ6�=�i=��>cE=5a
>d氽�#�=�yr�%>��>��k<%�G�]��(���t-���W="#>��1��t"=eM�<$>��׽7?:*]>dOC���ͽ��a>jI޽v��<T�=<UrJ�it���o�=��?=1�'����>Í<#��=�U���L�=Vx��/<�����>0ߛ�L�>aͽ�&�5��4�=�Gü�SX>�lٽz�:=rF=CĜ=?���P�=�,�<�w'��d>�D'�rz�<v�����߻G�)=fjF�+�9<~�`��Z>]��=�n6=��'�>����R��=0o�;�%�m%�G���fE��Y>?+�ccν��>���h��'��>�ӽ4`���)=> �t�u��������<�,����< ��=�>���R5�������t=`�>�\c�E>���<��*���=	���o����2>5E9>Q!��EZt=4L�<5���*P��� <>4�=F)>:�@=oc%<`�>�S�=R�m���=�:�<�k=:�=ïr�=q��Z>�>L���ɼ�=��&>->��>��=,�'�2V<g�z=ؼr�<�=잷��昽�����=�'�=՛,��-p<�8�=H�=.)�=@l�<���=�r4�`=(��=�<5宽�#;>��=�H��Cp�=�ɼ���=���=ޮ�z&�<Xt>9�)�J.=�	=�a����	~�<�#�=?��=gŁ=�+��1l��
Z�<�����ĵ=��=[��=�i�=j�$>b��<U�9q�ѽ�-=�+�=�D
>nӽ�S�=�N輇H�=}�;��q?=�����!>b�������B=���=�o��Z:(>�4��~#^�7}���c==蓽Hh�=��> &����A=p�=J4>�؏����<4' ���$�\��x�=�i�=.t�uќ:�7=�Қ�l2���{���Z=�V���?6=�
���˩=c�[���QBe=PB�ܭ�=�S�=���P���Q.��]�=_V�=>f����>��� )����=�m���>�Q�=*X��!Ѽ�����rK=$n�<�\�����<��Ƽ�{�p��I���oֽ��>�\7��4q=y��Z(�����@��#R>�9>$9�������S�>�M>�Büý���>��)>��=�zL��R}�c�=�*=3��� �=�I�;\��=?�=��=gH=�1�<ڶE=�����ԏ=�8O=w!�=T�ɼ(�=^�y=P���Vc�<��B��`_>i���yt����K��o<�]�<��=M��I����~<m�~����h>͡��S�=&��<�=D��=����\鉾U�/����̼
��;�/y����;JJL>z���'��Ed�i��=j����Y�=��>�7�<���=;�*=�$=��=����ʝ:�4��c�>�Ƨ=l/�Uդ=̒�=�m潒���%�����=C��ۅ>L���=jΏ��`�>(���.O�=�O�<Y= ō=uo>��=����@�=�)̻�4���&2> �E�%�O=B��,����M������*�<<T �ɖ�+z.>ڕx=Ƀ>�&�=�k=�<���=��W�c���)������2<�ّ<�,<
�->��W���W>��=/��=L=���*�=�C�R���9z��bx�"��>Y�'�&ְ=�2$�~�ѽ��x�',(�;�
�F�N� ��_E�:�z���,��3T=�+=!�<���; >=X�d���V>~�j��z�<Å�� �.߇���<�F=)�n=2��Ѳ�=Ĵ�=�v�=<�=��N=*�˽9:>���<;�Y=��F\%<�ϕ����m�����f��>ۤ<�{�=v'���OW�i�c>��ٽ�=х�=+�D���w=JQ�;[� =e-�=L �=#V�iR�=��=zos�v�=h�=���H��=����T�w>L��=���y�~�'Z��W�����7�>-Y_=t�<ex�=rb�=ʨ�=�Ǥ���G�P9J=��]<�Sp�
<>����6j���,>$���;H>4y �650=�t��H$�`�I����e���,=�9�:]|<b�,�ý�_���4������apf<�1(��*:��<=�x�������#<��=L�h=�E�$ѽͽ�F={v��P�V�0j��嬽@wj���=����`6ǽ;��<��~l���+�~��pe�=/ӽ<m��=M�%<m��=˶�,�_ �<H�ͽC�b��7��G=�s<:���4��Ô(�h����$����<u�ͼ�.��n�i=$S�svݽ^Խz��<��:P̖�E�����<�3�d�W��=%���}E��"@�� _����N�<R�ս�t?=�C#<���=�z==+� � c�=�;�=�w=�4V��:<��<<��)>Uj>A��2}=��<`��=Y�=�S=�<�Z�=���=�K�=��=� >�i�<\�&>�d�%����=���= yJ>���>�S�=��ϼ���=�\�A�^˽Ag�=��}=�ǲ��?۽���=u;<��p=:>�=�c|=�T��E�>��=���=5�Z=b�$>�d�<"R����J=���:Y=�\B=f Ƚ���=F�<C���N�=W��������=�-=S������<%$��\��<���=N�=��2>��S>��ڼ%[�쩂�[�����=u>?�E�E�3�����|8>cc">�N�>A��	ɟ>�tM=,=�>�"2�{z��M�2��k>kB���酽y�=E��=^�	�	@�=��j;,y>�\+=��>t��=->x��=MT>ad=<���㊶��O�<V6�5�A��r��x �b���E̽�L	������мx�
>�����<ż²�eT/��>��>�,Y>�s>��(���׽n�P�\&�<]@���N�ʹ]>J"=P[������=���>�(��N>���=���=�#��F�=EA��>`��=���>�߼=��z>���S��"��=��=�H���=A�X�vp`����=U�5>0����t�G��=t뽇� �[���D����>Z����=*�>�姽�at�ߘ=�}�=�+��>����M�R����=�ξ��b��3��}���<}�%���Ӽ$G=�M	>)5�=��>E{P��a�<f'>ޗZ�=b��{<!�F�=�!���W�=��U>�+��;k�>	
����<�;�=^�j��@�=j�>&<�;V΁��Σ�<P��]��3 ;=��Ἷ�>]>g=���>ϴ=��\���<���=U�=M$?>^C�=�ͯ=Z$���� ='o��C���R�=�ײ��Z�=��F���O\>#=�=-�;�^8>��2�,>��>v,T;P���(-�=x�j<�_�F�#>r�|=LG���>�i\=Ogz=YB�=�!�=�:�ތ>V>��%#��`�F�>k��=��>�  >�V��~`ú(����=�<�=���=�=s�F�p�=��&=b	>p��E�t�s�W=h�J��K;%=��W;-X�f�=o�=4��=��C>߯^��k>3���4d����!��}�=�ٽ=�L�:��w���6M>� �;�ޔ<#7�<Y?=����ʭu;~1>Ҥ�=�_=�>g�I����=���=vK�}��=;IĽ���<���y:�ޜ=���!v�?�=�e=�����n\g={��=ֿ��[��>�p>��3>�y�=��=$�>ⱼ�Cq���A�
���E>�=">p>�0�>L���9�>���:^<�<>�� �c��>6f>�H��!��<���{wc=�$���_�zSf�/�!��b�=��ż�V�=�Ft��s1���=�>BB�=��]>�>�����Ղ�)P���:�=�ྖ�<�$>[��=��= ��=�f�<&��N��$x�<.s >�a9��B> �[=�s;9M����6��='�9��m�=�����<�6�=G:v����=��=���<M3�=̣��<����=�덽�m���_��p����Ҕ�s�
��=�t=ر=!�e:�j�=�,�=��<=�9C6N�[FҾ�f>"��<>��=�g�O�->����I=y��=G~>����3>�4>P��9Dh�X�ؼ3��Fg>�ʚ������s�����Rʱ�����}��=k��=�Z����=�@���>�=��<Q��!�K�Vo;=S�ؾX�ȽQ���e*ʻ]X���>G>[ϥ=��<�s$>�Q�=��%<���=Bl�U�>�7������c�~�}�`$�=P8>܁\=������>W���X���󴡽��6=�D��C\J>篾dBr�՟���)|��뗽_*>���x=�����t=|�<�]= ˻ܥ>�Aо��>�J�����c5����=��:�YL�=]$u>�B��}�=V�����<�m��5�=��=����¥>�ŏ�6�<ԝ��i&>1��a,�=Y8�>��=�UϽZ2>�vk��`��� �;;�����=���u�����>��ھ��>��=��}��%��=��V=���n�=-�}���'<�D��l��=ߒ�;����=�Ծ�e=6ռ�!����岾I��=@�a�8T��"1>,'/>J�E=^Ӓ�,�E>;�]���=�+���=$��=�b=#��	
�>�m�=�r=�BϽ9�=5��=A׎���A�&>L_�<g}=��d���u>��X����1=�6�>z�=m��=J���Ǽ�TR���>�G�X�o>�\��La<>m�%����<�
�=e݂=��W=@5��A��=�9/��rN����=
O=K���n���i>-3��I�ཿ�>�O��t�j�G�d=Tv�� �>Y��=u�2=�O>{!��o�=hG�<����nG�
'7=?w����^�;��=r�1=���</6�<�;=�-=��<w�	�Ei>ol�;I��=�?<��ʼ�5�;wN'>S9=��8=I��<�X ��Ka�	�����=#F��VAp=Fjm���0>���<����C�T>^�I�WZ=�=�B&>�˷<Z�[��S>:u�����L��=�yD�7�=4a>��+�Y���W=���s�_�/+�=���4
*��r��ə���h��f*=s:��'�>��<���=���ot=�J=�T���B>��>�$ؼB+T=8���(���K�=�=�խ=�v>~$�h�����˽�M��4�Y<�m><U�Wgϼ+���ϼ>�Ž��>�2�<��齫�j=�����=P�!��MG�r	�<��=֍�{�=���<���9Ѽ+||��=O�9���=>�a>�����>��=�:>|�� �X>#鋽��Һ�]= )>��*>�8>���=3�8�d�=���=� =xf�;b�4��^=�k�=�}7��6>p��=��=8����ွ�ܔ=l&�=�a;>a=F?�$��aǔ�f�$>^�	>�'���=��V�k��ꬃ��B+>�(<sp�ۙW�o	_��=~=����Ƥ�H
�\���<�_\���=��X=A">���(P=-�H&2��&���_���>����t����j=��H>My�sd�>����a�+>�<EW�=�����G�=��=5[�<�菼�n���E<m꼞��='�	>8K�j�S> ��=��=/�}=�g�=�e=~��=��9=	p>@�
;HÊ�h���X�=F���K��_8`��>���f��=��3��8>� �<>5,�1`�T̽c�>���=2�_�)�X��ÅL���ν�.@>ТI>]�V>v:*�91O<��b����c=�}�=��6>�r����=�_
�g'	>H`�����=K� �kF;q�=�F>_�3͠<������I�=�-ƽ�F>*ml��<�">�;P���Y/=�t=�V
>A
��/��=�f=v�>j=�=�����>��b�Ƽf�'��;��,��|=b/J=l������=lpv<>���T
>=eʽ�p�{��hȊ=��齇>���<w=��_�G˲=$<�;1��;���=%X=���^|�=@�_���>�i�=��1�|��!�E>QB���qἆ��=�υ���-�Φ��-�^=[ꤾ�N�=Sx��-���=���`f�=���=�P�Q���o��=�'�=>��=�Ɲ;] =[ec�䁩=*�߽դ�<}">Ū?>��ڼ�'�=�=�c>�$p=�AL=�{ȼr���>�e<�KT����^o>�r=�,�=���c�g>:�8�񪣽���iJ�=w��=>-=F�H�4���b��=M�m��t6��#��4p=���)>��z=��]<���={�'�'S=��,�mI�8�8<;��=݆>�3P�ԆE=6H4�Z�<�˼��f�4��=�^��99=3t��J��K?��<rν��O��n�>P@?<��H'=��V>�`ӽ��=�'������"t�=z->�W���׵>�,w���N�Z��<�VG�(=���=ڃ�>r�y>��>v��������o��N���,u=�WY���e�I�����.u���T���;�m����������~��=:ݽ�ȶ=��=y�c�����D=N �=��'=`��;��'=6�ƽe�#��qU�Ɉ�=�T��|��6�<~����;��ƽИ������yi�;6/�<���dx=Ƨ�Ǟ��� =s����7�6~<����R:g����BB���<Z����L�<�A��x;��U5�<�n	���J>�4�p;}�
�=��e=�d�=�Fr�؎�u���Un� ��.,:=�ێ�U�p�h�w�Fʙ=�o���=xq�E�J��s��R�ؼk�@=nT>��7=���=���@���p��=Lç�w|�G]�� >�%=!��'λ��'�?=2��=��\���0=T�=���=\���*�����8=��ջ��$��5��A�=ov����K>;��/腼��>6hK�Cu<=s�X>;��</�<���=�`P<q[��X�>ǚ�t��������W�w�X��=nM����sU��M���ӗ��TL>h�>;|��`�=�l>�S����=o�=J#��>^=);<�;�<��6<��=}��=�x<Nk���=F�;>)�'>cn>_ц;�B>�l�<�>��Q=S�>�aڽ2��<��=�s�=�Q@����=n�<*4>���x��=�H��˽�Q�=`�1���O�L,T<8��T�콅_�E	Y>�\ɽE���Ђ=F>��`���w=���<[Vr;���/���A�>�
h�=!򊽨�E��f�>:'7�� ��ؐ���c=ZY���<�v9��V�Gz#=k73��}L=-��=�g��lz>����������`͚��ł�d��e�=Z� ����;��b^>cb��C�/��=�>=kE[��[�<�=�v���a=��F>8���Ɏ����G���ܫM=%"�=m'<>��2=x&�=�D��<��=�4>zHf���T>�C�=_�=�4a��F�;||�=���tDн� >Q�> =x>�=Ծ0>ݸY=z���*½�P�
u�=וs��;�k>f�=��c>�܇<�ȥ����<V撽ὧ=�>k왽�K>_�=��Z>�J�=���=�te�[j����>Xb=m� >ݺ%>h�νJ l=E|\�n�:<X�=k��=��a��fA���v.�o۽._�=���=�����E�=��B<�TʽF�^��)��҂�=����ŉ=>�P>.� =aLy>�0=T�7��(�2t�=�롽ց�=���<��>��>��O=���y�=ڷ
�ɪ=cw�=L�=	���=�<��=L�޽�a�<~x���Ƚ������=M
���!�SN>J)<rh�=�=��X�^#<Vh���e�*�>�k�<չn��p�Im���5>bܡ�F=�6\���t={f�>8M=o/"���r��r�z�'>�'�<��˽�ة�J�Ż�5�>p/�=���+	>���<���<pc>p�����>7��<����Ng�=b%��%A>aq>��[#�;2>��;�5<�d�6C=�~,=�VH=�u=d�=se>>�ى='dN=ɧ���B�<w#==�f�=4{q>;�j�7e����>�L�=!k=I�'�C��=����难}��EO>	>~�x���=�H�=��<�&<���=���#D}���@>[d��A$��$>;�;�����Qཅ��=bԢ�ZY>{��<3̔=��B=�0>dE$>�U�=���=^�=h�	���o�(#$�H�O>�6��+��=��>�r��@t[>m��=��>@J�2��_"o��6���zv
��7h=K�ͼS��=	S�>.�=����N�=a<�<�[>04X��R�<4Ժ=�}漑n��~6���>�>@��>�����!7�"���+>����4ѿ��K=?X�<0���XZ�;}

�}�ٽ��}��<�D4>L��=5z��h@�=޽s6R>܂伨�W<�ƽJlý���<u3>��=y觽X���V2�<�E�=h? >("	>X(�=]L�=�3��B�	=&�,�����6�=!'K<h�I4���j�<n
(�D�=�I
>ƒ�=7�弘ػ=g�1n����Y���e5=|� �%-p��E=�<A=b��(�8����<��B>0��=_��Ni>�=�Ċ�?�˽��=�M�%>Nd���I�=ќB=��;��>�gZ=�6�=�ѽ���ٜ�S�>���=H�˽,b�<i�9=�/><b����Y>����l*>5l�=Y��=U*!�b廥q'�o�>lM�c>�O����k����C%>����r�$>7�+�LUͽr����z�>2%�q�`>�< �=�?>���<�R��=��(���߽�4�<Q`ż��=�Ä�E�>4ʽ~CP=u>7�_=s�>�(>�Y��=��;��w�y>�Nm<>4<��h��k:>�_�=�����^>?F�F
���>�@T=c-I> �=�L�;`SX>��K=��W����=蕔��'���o7=��(�|�j=�WA=%��=�Bf�^Ľ�\=8 /=*������=ϡg<��H<��>��Q>Vdu��,��o$O=�]�<�j�=-��&��=8��J�<eZi>	Z1��-�<�<j-%>���%�-=?���j��������>�4Ͻ~�e><6�;i��=���=�|�<j�0>�������M��>w�@=�~ؽ�\B��V>&ኽ�-�=�}��żgR0>r���=���V>�$�z�4=2�+�D	�=�e��n�h��=R�>e��=���>O��TP4����=���a��X9y��<j�X��#6<c�=���=���m��j=�>
����=�/	<�>[o�_��=Df`>@�(={mQ>Ո=>h[�<���<'��<���A�x��==�‾%�,<��=1{F>�N�=�)��^/=��D=Ѣ�9<��<�s=��4>��==;n>�\�=I�:�2=Pv��4��k�7�qi>q��=x�U��\=.��tϼ}A>kr�x�����=�y�=<Fʽ�:X�ҽI�E>�V%>�N>���& >�ht=��>o3����%�O���9�=u�_>#ӽ�0�=�~�;�����[}=��ּS?�<�%�=��>���2�<a�ӽc�>}�=�X�<�6��K\>I��pw=��>�/�|Bw=)���W�]'=lk>y��=�n��Y�h��.��6n����=���=�����r;� _� ��=q����괽�(8�^}޽eC8�xQ�=<�&���=������<P����>D��XŽ	e6��_�>�UE>�s<,Kf=����>�J���+�w`=��q=��=��:�!=Q��=�3A��i�__�=�k'>������<��<�>6>>����q��i��4)	�<��=��`=�h�>�����Ǽ���=���B�S4�+��;ݒ�=�v>bY�=OB�<��n=���<1|(���A;vFz��\�=b˻�N:<�'�=R�A=L>���=@&Ⱦ��>P�x=��=�b�C>MP�=��@�9�=�x�Q��=�-)=�;%��_>)�=-R����CsT>b~Z>�"=�6A<iH���;J��=x'�=��>��=,ը=�"���W�Kk&=�����=~���S>�'�=@]>�=�����t���0>f�����`��/>w�*=	[����=��>"3�=���=$�=���=�"8>$hc=$>Z����=\�"�&��䗽%��=�>�UZ�M4.�6�<�>&H^�{��"��-��I�>��B>(.ǽ�7 �6��=�Aq�o{%<cMo=�f����޽B��=��<|/�=c�>A�޼|毼]d �#LC�\��=�[�<~m=";̽��{>?�=#�.>�Q�9J�<�H�P�R>M,X=(@�=S6�����e1���,==���3o�>tl"��S�=��/;�:�a���rҼN�v���V=r���1!~==d���f�����0=-~��mFy�3#Ҽ^�]��=�"�h���E�6>{ۓ=�W�<o7�X�M=n~�=�Z��#̙=/5(>+��<J�=t;
;0o=d�<=���=4N��[z�;[ý2d���=	��=�&���b=���=���=��=�������=�M<,��0Ʌ�{�7�n���|�����<��^��]��w9�;� _�sǽ������>��dy!��og=�C=�l� �=2�a�wh�Y=�F�����AÓ����=Js<�$<� ��4�*:޽*� ���ͼ=m�牡�*'��4�ӽ���=T��;��<��㽏f�-��`ν��ǽ4�#=�7����@<�e=�#`l���<FDg�G <�T=�Gֽl��؀�U��CD�:�Q��}����=�(�=ƶE<�`��'�<SA���I�=�Os=ݣ���ٽ� <ݡ=����ڕ�M۰��Zh=k>ܦ`;=2>�)�_)�<��,�x��=}i��0A�<��=�ꋽ�Q�%���e�e�<������ƻ� �<�_.>�Xe��`(�j�=Q�=�x���>�=���:����������>oFR=��F��Y=����D�=桞=�Ы��,~>y|C�y��wJ(='[j<j�(��g�=9H�=�x�=��[>~��>1ü��=n�н�Ȼd�= ;�
��L7ɻtG'���ٽ)�徙"8>a�H�~_>�	������"ގ=�Y��x"���ݼv�=6�=�p>y]=������>w�*�މ���x�B�P=�B���GN�!��=�<�=���;\D>6��=ݱ�"`d>�b�<��=
=�T��z
�܇���'G=)�%@_<G2�=U��<��=ja�=�$�=�k�s_�=G.�=vH�=Ŏ=z��>��=��
>s�<�Ca���W���$��k׼ ��=T�=�v��k�=�]:�T��:U4=��=b�=h�ֽWN�K���JO>�$>%���">�f�<@B��R>�[�r�>�W	>�J��<��=Q�=�}޽Š�<����JI�~��</�Ҽ��;��y����M�㻤�D3�=<��<K�=�+>���8�u���:vH���D���=�T�`]A����(�=�5z=
�<��n6��%�=�䃽��P���
�O���1~���>?�J��~]=�����=�%��&t��L�<��J���=��d=�<�Y���� �����k�<Pu���(;=1_�.X>�@>�a�9�qW=5CR���^��h�>I�1�a�SZ3<��I�jϽ��;>��D=WN�>2�A���_X*�	T������	�{<\P���ܒ>J�t;������)>�����>��6>\��=��ɽmA�=��<�G��`K�a�;>$�<$�!�7y��M]����>ܳ>��h=��r���=sH�=5>�ꂾ�}E=�<¼�r=�_��9��=���=�I��ض����=#�=Q��ٳk�Ҋ]���½|����6���)Y�'��&����g=$�!>�]�B����7>��C�$y��?��a�=�A�=�Y>�8>�g0=��=k�,=TD\>jء<.����]��F�"��e=��=#DG��cc>�ݼ��=�"3��襾aR�0�k�֟=䙽H��+��=��C�����*8���=? <���=�h=�_�=~]�=G��b�=��=�ז����;��=q���ӹ)����Y>�G'>f�j�X�þoLj>�� >�A��`�<�d����Ҿ��x�8w�9�� >�"�%�ａٽŷ<���S.^���>���;6վ�)�<7�>�~N>�W6=��5��=?WG>��`<-h.�ky�����=i�8>TZ�Wؤ�������:��W�=��=��ͽ��O���\���Y>�FQ>�ͽ�=E>�b�;�/ �~9a<T���Q4Z�r8>m,�=�H7>>�)>�(�ͷS���3>�À=0��=�P�<�/<_�w;�-����=F�ܿ�<G��=Z�=�(>w�R��È��?��ܱ��E>��>|�_�O�=�f�A������0��Y�����f��<�r���=�J��9��"q����-=�{�)����o���=x�f��k��G[��S������#e���.�=��f��cy�S#�h�1>,>�����;�ѽ�y<��/�����
D���7>�
�=|�=���=ԃ̼/Vý�VR�Y�%��� ��=���������?\�=��
>>U�==� �=���=�]>�J~>=�=���qѽ��=[��=k��=#�=3�>_�A=av�<&�};�ӽ>�'=*=�=F�>���=�>����W;�=�<=���he��w�< 8->�>�P�?�	�k�=�@ =BA#>�I�p��;b�S�0�=��<����r�?=��<��=;�<�c��)ӼFO9< ��<�B�=*��+QܽP4=j���=,�_�*��I:\���=��=���-?�<��=�1=a�y=����k�����ٽh��=�#���>����;t�ͅ�=�|%>E�;��1� ]<���=4�=(�O��T���m*�i�_��P��z�=Lm>��z���<�n�=�y>!<��v<V����=�F���i����`��<��=@�N�7���R�,>0�J<)��P#>o>��;�Vj�=qύ���>m�>�,_��,�=؂/�_�>b1R�����~f�;��߽�½k�C�"F=���Q�=Ѧ��U=F	�����]�N�i�@����@���=	�<N�;�7=NPQ��s=%C����r��G�hV(>�"{��{�<b8>`�Ž�T��2�N�D
�=Eb���K}=즽&fӽ��=��=�T�S�<�^���N!��U�=��=�x�=�u4�:�;_;�=����m�3��(�=�0�<��]>��=]��=��8�{��J�I|ɻ�C�=����>-sG=H�=T���}����>�?�Q؄��1��z�=h"���g>u��=(Ղ=�ʽ�h>�Nɽ�6>>W4�=�d�<��=�
>�!��1��l��=��=7ӗ�)��� ����:�=�mU>���<�����=>7@N;XBX=���=��<5�=���=����.�>�[>���<p�_$�=�>'aܽ�S�<MpE>V�e>�p�=�:a=��%>V&�=
%����=X�=j�Խ)�0��>Wf �:D0<c��=EC%�����J�����>�2�r�޽Ӿ���?�NiT=��>
L��I����b��s�[ƽW����<�BF;�쟽��2=`���-V=kۺ=?-�L�T=x��;j4=�X�z�L>@� �րE���->�@�<  O=��:Kj>_��.��<ܻ;�Z��=gB@���>���=L��3�����+=�$�<.=N�k�ս] ��"H����t�=�k����y��=!�&���{>{n�=�g����T=85�=">��j�y��7�]=^!���3�=�u�;�< >�aŽ�����>`�c�=7�->R˨�=��;�����F>��
�`�>g�׼��'����=�e��� �=:��=Ǎ�=�R�=��CŇ=�b�g����c;~��=�j��;<�lD�[�c�����M=;CԼ���=�� ��>�#>����@�6��~n�r���
�=r\Ž������4�a���w9=۠]=,��=P3��[�>x��=L�>Y>7���ڃ<�~�= H(=Fz�=�(>�it=W�=_=r4�<=*#����������=sշ=7�v�z�2�Ch'>8��<E�I>6L�=�ϻWa��Bk�=���z?����=�E��Sf��_н[�սHI0=��-=P���9��=�B�=�9� r�<�M�<k����׼z=W�����=D���˾;��������=%c#��j��F|��*�j���>+��=ٱ>����Ѣ�9��C`=��ν�r�ٷ^�{8!>�?P����=h�.=k��>jM��n�= 53�`��<���4�=�H�>gg�=�b<�,g=�k�>����D7��Z�=u-�=�E~��NO�%���2��?f�=o��	�@>"j>��K�>�+�n>k^E>�JŽ>=>��>�J�=��=� ]�Ͼ��W��=2�.��ȁ��l(��}=�҄����='@�jt*=�LX���f��J�r"�=t9��̖��Q�.>��;K�νIm��Ы1�,3�=�4�,B>`~P<�=�=~z�����')����E	ټQgm>ϓ=F&=K6>k��<0��=��=� >��^�������¼R6��6ʩ�~��<���G���<�E��������=Y�=EQ����=R;���=�U�=r��-�=���<^�:=�~�a����,V�	�8�������>O�E����0����gr����=A��=���=݈U�8�=�`h�bkv��0=��V͊�H�1=��=z�=�S%��8��~�Yk��.���ҽ��>�
���JC=���<�Ֆ=Ɋ���!н��=�H>������>9Ӷ�<;>=�=\���=��R>�%�=�{��LE9���ϼ���hX=���=�ƣ����=\��=rt�<���=���l�=Վ����仿���p��=�g�=�ʖ����=�r�=��n>eV�����?>�����;@B�=��=9v)<���<�K�w>��.>�劾+?���o>��6����=�n�9'C>��&>.����A���=�o��r�4��<��,�ĩ���M�y��<�~/>�m��갋�>w@��&��$�Κ�=3�"=�>��ս�xW�${�=Q�">��2>���"��<_l�=��3�n
A����;�m�<���<� �3����b]�=:�=A�H�Ϛ��]Q=Q<�=�|H��:����<yZ�J:�7�4�{H��]i>����=��H����=N��������">� �;1c�=p渽r.$>��2�w�0/��)��W�����=
;<&<&>3|,>WI���M�=��N��=�Z >X�������/��oU=���<���=_�>/Qc<؁�=d�.	G=ꥌ=��6>#��"�= �ŽF}A��z�=��z>����-o=�� ��E��\�=T>�=���>۔��_[����4>�z�<=�X˼�:����>z�ؽ�D��H)=,�+�\,�a����'�=�;��8U�V���&���(e=I�H=+�>;�g>�ʅ=��<����+!��ɼh0�*��e�=��R=o��<��3����=1��?Ni=՘�H��<��b� ��<�=�#�;��]��k�=�Խ�=�"��-ӽ������߲̽�~�������>�Ѝ�v�J�K�D�Լ���;痄=+#>Dފ�ױ>O����ؾ���<F7=�6�=J����p��G �>'�ֽ��>@so�Qܼ=;�>b�����=�$�<H�	�M�$<�Ƒ��\�5�3>��=}J=�B>�c.�.1�=��f= �>��=�i��L��$>�W��a�f�[�c�J #<8�4�5�F�'�=��\�K��<�?>��F�<��Y>       �;��l*��n����=0I&=%�O���ҽ:�=5�>;���<�(���t=�U��T�c=eHn<��<��=%�4=(�>��=       ��?��?A�?i��?֟?���?L��?,�?¢?@��?���?qۗ?��?2��?�U�?M�?���?���?v]�?�H�?       Ҙ���z)�gH�ay�Ԑ9�� �lp�݋P���h�ߺ�cX���a뾧��F>{�ؾ�SɾE���0�����L��       ���>݃?���>mP�>�>?QK�?)^�>M�>	�>��3?�E�>r:k>��>?-�
?��J>m�>e��>Ӆ�>x��>       �+���<��]>{F�=��D;%�>�â�Rb����]�����U�8;>_��=
Db�-��H(�=��Ľ�0>5��=��|>       �k�?=�@J1�?%��?81�?!�]?k4�?�1�?�o�?k��?��}?ը?���?i�?���?��W?�;�?A�@��?��?      �Ћ�cJ$�7�i���;b�m=.v�	�=}��'s>G�b���<D����=8�<�iS��	�=y�l�D|�c�n=��'�uU>�,G�8ܹ<��M�f�D���:>/b�=/-��j!����5<�O�R����=E4>�Ή=@\�V�>���4�}�5<t�n�V�!�i�0>���>�=~������K=�"��z��W�<�L=�r*>=��=�7���ʽF�&=�n��i5���A=\B>6�c�G����[���L�؉H�w�:��=kO����jý�{�Qa>j�N�ì#>9LϽ]���yl���8>��Ǽ	6���#=�(.=TT<�ҽYM���=]v>u��=�����%==�[<6���[�=)�}�<	9�>On�����R��<�ؓ<)�����=fd,�GE��f��\�>��=e0˽3<�={k��E�Y,ν�sļ�^�=��;�3<� >��>�Fr=^��=�b�ʶk=0���%㽩=���[
G=��;9J޼�}
��gD�#�
���=�����W���=���̹��P=E��<S#>"�3��:C> y�ecܽ�A4��������=�w��WN�<T��=v�?>S8>1˽O)	�=���R"�=|i=�$C9��=Y�����ػ-�U�%�7=����_)<3�j�>���>�ϼʩ��
û�G$ =�7{��'�=̚=��ٽ���=k�>������<���y:����F����>2���N�D�Z<o�<��ڽ�j=c��.K����Ф�<�ꇾij��Z7ѽ2a�=�G�;�(=ޯD>j� >ma>�%=e�0��ؼ������:���٭�=�ɽOA>P2���-�~ r=S�<��ؽ���=��k�c�%zO�����8q\>�������Ĝ�n_�&���J�>�� �1�Q=ȨZ����:���Y�+>+�==�x0�l]��"j"<�[�%,Ѽ���{�㽞��<�*�=��<=�o¼�)�=p��+�
���=�H�|�/��Ԩ��48>����4��<Ἦ�U�+���T��@�=�%r>�f=y����j=��I=�xK<Ƭ����ѽS�B���=j�P>�;��-�s=��w=��K=�\�I�4��敽�p=.���܅(�F��S}T���X=|O�=���=��"���T��>�o5>o���^��8�˽!Q���u>4�V��:�H�=���=
���B�+�<~�;qÚ�x��=�ٽ�� >Bm��?�>����������x�a��=��>d���`2=�Ù:!����֦Q�D%�=�-d�U��\>碯����a�*>�J->���=�	��A1���V���>� >��徫aͽ��)�
	>s��O�=�&c�U��D϶�
�X��=[&Y<7��=���<闦�����T;���l�=	y��Ńt=��｡I�hv&�b!>�Z��f���@g>H����d>�8�=jν�ֽ<����EMȽF�;��B�;h�c�����*��u)�=����oʤ<��_>�U���(=�Ľnr�����/�<a��<�ɵ=��>t� �4R��Yak=;��=�W�n�K�<�<���=�d>�����Z�߽�<���4���!�����N��㝀>�ؼ��A���d<��+=�*����=�� ����=Z��h�R<j��N����5<������=5؈=9%��P[=�j�qH���V=r晽���=�����`�Z�$P5<�\:p1{>���8g�=.� ==��B�˗�=ek=�>	�Kx9>��<=>b�=P刽�(�� 8���@�#>ɼ ���>�
̼Q��`�z�B�>>�J߻}���*>�L����R��Zp��e�=�޲����=���=�Ӹ��:�=�>Q�s=� �@ ���5>�Y��d9>|�7>���
����?<�ׯ=����!>�6>��=�O=ɬh=�p�HB>��^��B�=1�x=%<%b>D�">G3[=ATo<!0�RR=`�;>��Ǽ6�>7>}�<���=��k=9����Z�;�ҋ=�X��1��Sa�nP<M�>�%L���&<��\y+����K�=>�>�n�~!Q>V����Go��y=�0?��{�<���= !-���]���/=_��       O:�?��?搘?��?.�s?0�v?9�?�_?�w?D��?�}?0߈?ebf?���?]�?\�?���?��l?='^?�?       �>��(�>$|+=W�$�Gx�=F��=�	��������D,�懚�3���g%�qÆ��4k=�� �>R=9tV>A�5<ӊ?>       ��3��7�<�S>*ے=#�;�T>� ��cdM�	5|�V痽e�0��W8>��=W�i�5��<�=��Ž��>ҩ>��{>      �$>m^��Bh��s��K9+�K7->�D >�S���%>Uk>ڶ�=�]�2�����=6�=���*�<g�=�r>�S���X>�3�>�Z>㑣>-�%��׾���<�[E=��==]=�%5>Rf����|���U=)��<z����i�]O5��xM<:�=��B�������n�T�<�6�=��Խ�m!��;���=���H���\�k>��;>�0>��]>�mؽ��:e�q=�����m���ը=u[=1�ƽ�&�=�5�=7w��Ϲ;��;=o��M0�=�ĉ=h��>�؆���Y�Yw�����=a�H�;�<����[���}��<�$�=��>�b���:<E�>�S�J�Ի���=���=��y��k>>�o�=��/>��=ӊ�=�~P= �~��с�Ol�=n�,2��˽#�Ͼ��,=��d�]��.����<���=]�=�´��D��P̛�Й�=�2�=Wh�=M�>j䯽���u~꽵�>�z>��*<~*��#�6=�N>U�н�GT��B�;~��=�{f=]�E�������=쑉��U�<�sH��h��4��=̜ҽRp=%BJ=�Y�)�;���;�?��=/���Zt��x��R!;��=鋒=Lq=�,�$ �d�=��ӽ�q��3�<(۽�lN������=��&>Ir�!Dx=�XZ��"~=h����̓��5�=����ej=�,�D�佯�ƽ�KQ=\׍�Xl�����N�˼�g��=d_#�"�,���k>�L1��#��~Oʽ�*Q=Pt>���=����p��D^A=f��<�bM�QJo��>�����(<�1=Vz>��:���P���g��8J�y�����.=DQ+>[���'�>ޟ��/u7>�=~��[�=,����ɸ=�T�<���)��-jؼ-͛�-�=Ǜ�����᲍����;oй�Uv�=sR=�e��I�w)�����=���=��ī>�8<��#>��V�-(t���=��	=���=.G�=B]2>!�;��`�p�缒	��h���U���t	�=^w���>��
=����eE
=B�>�����p=w�R��K>�����|>�:8>>4�׶�a�B���N���P:r�Y�i��-�[�!�뾶�>�"���a��y�<����G�ؽ�ͽ��w�r2���
׽�|/>v\����üyν���=BM
�zB�<�����<q>=@>>=>���\\=\�n�1�=�6�=�>)p�=N)i�>45�sC>+��9G^>Mj������a2�<m��=,��>��=�g�=ˬ�=�lz>���m�=^Lڽ�(��Ȩ=K_������ao��L�i��=Œ�<��ʺ���m�><s5n��.�}�<Zm�=!)ܽ�5,���=�n�� �ɽ��=��0<���\^���=l���-{�=�q���ߠ���s������ɀ�dڡ=7@>��B�Vm��V y�a=������� E�1A�=u��׌=M�:>��<�A>-�n�)p=��ܾ29����0��=؆H>X.L�kD�=�Sd�_ҥ=ڴ>�������<��=e�%<�@=�(=�X��CD>�?��>,7>88Ž����3�=IƔ�J�=��x�Pm5�4��=��=h�w��ͧ=X�~�)I�=7�=�F:���{<\�l��;����0a�=#lb=���=̠�=ވ��G���k���= �Լ���b�==_��>�=>���=�kѼ��0��e <T�	���$��=�;~K���Д;3&���3�<�y=������;�W>�
�<L�;>*�=��i=<�{	�<�+<�9y9��.=2:�S2= �W��)f�p�Q=y3�</�(=��3�V+��P��@U�:�x�=;^ϽE���ʛ=�ge=�������=dz�<�!�N<.	�`'=�~=�w>����Lk;�/� �>Ug=Ѯr>��[=�1;<y�>a����Ȱ��L��&j&>�b%<���=8�>�}�=4�K>s�T�Րf��N�=�f��*z>���8�Ǽ
y�=*��W	>#����T=��=i$���
��ࣽ5"=�&F��!�=���������?�<�_���=i�������C9I����0�;�j�=$���XL<�Y6�Ut"=Т9��q��@E�bv=�����RֽK�L���=(�=�Kw=@�>U�=�4�<�E�����=p42�?~ڼ�=�tH<;_��y�=x�=�R����=�a�=j�����s�4�-����	>A�<jw���C=�-�����<���6��^=��	�Vu>��>����2���#����ѽ����
>��/=�9�ʍɼ�%���8׽�����?�=����$>�)�녕=�^��=+>��=��}�=q���<9X�<�-̽��=���U����P�r�J�s�le>`�����=�C=9ӽ7�T��փ���=ʙ4>潴��<Q�'<?)�>0gs=����]>9��=�)��eM>�����d�R_���2=��	l��"�/=���&n1>�i|�$�~��5�=83�<����b�<#���K�>z5V�o
�B�-�=�п,��ɼ""O���<�
>�r�=4�"��i<2�#�$`��#1�<L��=F�9�B�=L�>��g���=�T�<$�=Ԧ=��l=����k�=��>��=P����GQ=]����03��|�VD�W�	���{��4��9��=�>�]�<f��=��j>ӟS��P=9�=�Ѯ��k!�i=Q>G=>J��t��|ܻ�h����Z�^}�:oĊ�d�Ľq�?���=r�ȽZ�Z�W'=}͒�N;��{��=x��v���]ʽI��=<�2�t��O��<R"��d_9�o�=�����݃=Fu=Kh�4��>8P>gռ5�ν�*���^=�Zt��B���R>����X�>�Hܽ��o>j � w�=�
a��֮=Mod�{�D��>R�`�޼F~'=d���JAM� ���Tp'=R>>�K彭>>x,�>9���i�;M==ꄾQH<U�<G$L�-N�����c�c<9G@��a>�Fg����;�����5�H?�<+�#����<�r�Ӏ�=�ļ�3�>��?�$�=�������<7�=^o=���<T�P���=��ѻ\�n�^}��!�m�*���i�!��GU�=o@��NzȽ϶'�R<{���`R�>�����<:ǻ��j�< �E�FA�=�+�=6|�P��=���=��}>��0x��<���+�Žצ��:��+�<9��=��=0<��=�ܷ�:f �cc�=H ���=���;HKc>2!����<�\�_\Z=H��=o����i���1�3�D�4����p��=錟>���<z��S��=#S����=T��=Öa�����㐾�$&=�F��op
���P�Uw�+�ƾ!Խhw:�+\�<�t��2���M�=[aa�S��=CO>F���<�����<�*�����<���c�ּ���;%݂��7��W��_V;��]=i(�<ؽ>W�)=h�q]<Yg˽�e����)�n��I��0����U��iw<S��=lt>�[l��>�h�A=��==��
>�=���=��"=x��L<D��q���H8=~�'>�<x�4={�=#;>@��� �=�����=�����=ZeH>���>=Mn���3,>�4���J��t)��8̾�(>��y��p>q����U��V�=�c�=�C�=�'��KҨ=*��p%#��t�=Y4�������ߊ�:a�"�8=nܶ=d�>=>�j�=OI�`�q<���=딮��޽0 ���s�=��=�==��=D�=vX>�]%��A!�W�l=�0}����<�@4����<��y��Lm<��I=�)�A�s�ʝ��y�<�P�	�=Όμi��=t��=�<|>#<"=�݅�����Q�{:�<fC�=i�:���Ԧ=��s=�/˼�9Z�Η]�w��i�$�pc�=���J䐾��u=�n%=�"6>��軍'r=n�/<۔��#�ӽ�䡼b�=�=�Rb���ؼ�K%��l���+>���=�B��|�U�hy\��y�=��ռ����,��Q��<#E�=�2;�GJ>j�=r�վ	��N��=�9_�6�=Eɝ���ս�T��a������H>��~�����b�=?�$� i�=c�+�=�5=�$I=F�2>�U���R.�?6�*X��ͽ�E>桄�E�=~>}=5�����
���-�a�=Ŵe��C=�?pW=�ʹ=&���K\i;�:��[�H=�;e���s<����,�=G*����=�"=gA�;�q:�뀼�p*<9@l�8>81/=R=�����+=����V��2=����pѽ���=Xj��D=��὏��<:��<'��Y����o8>��� ���&���w��wZ[=�QR<��>�~=k'�=@�=�iѽ�>^��<�?=���;Y^��+h~=�o��塤=x䅻PɼwP�h���ռnC=�|=�I�.儻웢=j2A�e��;t`>&p����߽S��>)y�=���=�n�Ob�<!Y�=�)��L��L���DP�;T��7Q=���<R9˽*@d=I>����'[=�I �� ����#>�!=�,޽�D�"� �1>y���V����߽Ѐ>�P��\���q�<�=�(�\�<�ؽ����Z�<�m��E���x�6�=�v����=��¼�.j���Ƽ����=G��=��;w��=2�(����A�=����@>a��=^S=�I�d�N=7_�<��>ŻR>s�(>ǋ�=&<0ℽ
�ѽh�`���;�<�ǀ���oY���G<3��<S�g=8 �{��;Q��=�y�,`������Ϳ�&t=~�0�GE�=͖�<�XμS`�>���=�X�<mv���i8�X���/��I:��H���\���O�=�y�Å�>1�5l2>e��<�R��v>�V�=�U6��n������N�-�Ũ�=&��^�;U�J������󽧆>�/�>�c;�뼽:�y<���^�>LTɽ�G�<ǎ���M>���=�E>?�\=xE����<х���6���(%;n(�=���=r�D��8�=�н;�� >�EK<����\�2>��!=��Ҿ&��Y��;	�5���	�;�>��>!�۾�r��[04������;{�5�i=Nq>~��%�g���=�Yy>�V��W_�;_ƽ��d=#y���;�����;��_=�nj=�dn��T�=%?D��P#<��v�(���7='T[>L����d���<��üj����b�Pb> ��<y��	~f��:��+�=hf�������=`�f�>�4��?�
�,Y=�>�嘼�q>;�=�k���i+=n�==��=Ε�:Q��<E�=������<P��瑙�t�����GIs�������T��V&=e��=1 =>�r��ѻ��C<ܤ�=~��<�H�=�ˠ������=�%��6���H��r���_2B��z���@>�%���A�<�yS>u�<�T_��h�=����v�^��mQ>�����o��9;> ��=.����*����I��w���D�=��_��t�:M���U���f�1=;�B����<��Y���>��8����<��5>؋�;��|�,�A>��8�q�%��Ƴ�����׼n�>�Z<(�J�r���qR�����{��=������TtԽ�QL��Br="^/��f�+2>��<��C��m�C���V�T�5� �N�B��<\�<G>�.���g��7���i?=2y�=||�:��]��
��R�N��X����?�'�6�;���=縐=�8��Tk�>�D���+�zP)���ͼ��=S�S<�pt��=�L��=�|\�y�>d{<ؒ>�L@�j���)>ɏ����=vc6�H�M��\��P>��{������kd��o7=Xս�Y=.�Z����=��&=���#�>�y��Qg=�B�V|��D�);�2�=�r1�{��=�'V�3Ț=�ށ=Q���qH>�r�>��Ƚ�j�=�r��%�^f�=}$��C������=ob >�/�rlb=m�=�D�îF���Y���
;\�=�|�l",��uE���3>��<�����,�N�Ҽ��V<]�f�<�`7�l|W��X�<Q���X�E�=�֥�<>�P=���=������)�TZ<�>v��=�щ>��Eo�=|�U�En�Wb����F��٘>O��k�D>eX���)�h蟽6�K=��k=p-��m��fT�!�<%>�����s��	��=�G��d�����=EO>Ǎ���=ɶ*>��ν�����@^ｖ�F���+= �<�<}����=�����s��*�=_�<[y=V��V�.��:F�;r��=o�)=mD�=J&�=�X�������=ϗ��ivt����)��=�)����=@��='!���޽�`X����m��<�>�`�O�߽�Q4>ׅ���<��*b�=��нvz��̌=󫰾b�<8(=\PP=J-=��+=�/���z��q�>L�^=Ӹ?�5��Y<ýP���?���a�FW�=H��=�1D�l�T�~l�wo=%�Q=@�E=�4=N���^D0���!������=��������+��+�=�p�=�񔽤3e�D��鲥=XQ��텽?Uh=�!��r$�Q��*���p��L=)(�6�Z���o��l;�2=颡=Y�-�<�/>�̽�!=���<񗍻��<�ة�=!�Ľ�ѡ��>�o�=P�+=�V!��'>0#�;�Bݾ9`��-F�X��=t�=F� ��� <�i/�����)p�JB���DA��T�=뎽p5�N�<���A�*����=p �=`C�~�*�D"�=u"�����Xt���=w|^>?��󤪻^E��/ۼ�����\<ʘ�;Y��ej<�>�M>�N<��b�ّO�E��=�8���3�����=;�����>��<�w��Sɉ>
rb�ע�=��>ϙ�;ڗ�=kX��}�!��]*��"&�v��<��a�,ٴ<���=��S�����g����Ѽ^��=�tf=��	>Ț��6�PP���n=����=t>�M�����=���=@�@=�&>�s�%���ë<7&�=�i�=�[�aG�;�+��6ͼ��a=`i��_ּK�=���=U�B�^k>x2E����=D�X���ӼJ3+>i����F>�R��#=%�(���$��z�z� >e�W�9�/��>�6��ߔ,>2���˖>��
>��O�?iӽ��<n�|�o���\W>����n�R,���7K��d�=c\�纁=��>�� �� ��?8�|�*>BB������&�=!v=��<�h���V =�&ڽ���.3>�)��s����q�=m�H>[
=���[=��ȼ8�v=�k<�G���[�=D(�=�Z<�,3���6��68=i���bOY���<I�G>�u��|	�;Zg]�0�����=l�2�o�=c�T>2\=o���&�<`���^��`�=�_)�J���`�=v�U����"���������<�z�H�%<D�����K�5��=s����gW;�h3< *�I����==�=��U=y=�o=8�<�� >��n��+���p�=q<�:~D�=8����r0>�����4.�|�G� �:sM����ˁ=�}>��<���x��=_�1�vu�;"i<i��=��˽�28�?� >��<<�X��e	������=b��w_�nQ�<F�#=Œ��N,L�������<n��s�w=hs�����>��)����������%Q�y�3�X��=�<�Z��C��=pG�����~H>�2�x�=��=�8B=R�M�ٜW���/<��ѽ��6��t�=����[ܼ��˗��KŪ���ϼ�V���N��$0�=p1�O�E�+>`�˻��T����)>(��8�=T��=�f�rC��j��_��ْ�<�������=l��<��">;���s��C���z*<H��>�">�����!�y8�=����G�=1Y�~f2=�Ax=m�e���<�/1=��j�MH]=�?��|�<���q�\;���L|��>V��E6�\��>TR�<��u�f�= g�Vg�@͐�	q��`�s�J<�m����W����=Hg<�o.��I�&��=�=����������<�S�=�]>��>5��=A��=� 9�Ɗ<<@Y=O�ؽ�pԽ�� <j�Z=��<�����k>���>�5�<�`;=認=~��-n�=HZ��7�=�VT��#":	�[=h{Ľ�j�=���<ؽ>���EC�p2��/=K�->�$��l׽
�p��ī�U'�5�!���m�=����E]�t�u>lL�ï�����<�V�;A`��H�=��=WD�bhM>'iV����>�#2��i,�Z�@>2�'=%�>l5�Vn?=��>����y�M_h�}�὇�2��,�rS�G��<��ؽ���=���=2��='����?>�������I�i�*}�=
������]9�",���=��'>>k��a� ��JϽ!G��Z>�>��μ0>�m��=���=Y�-�oG�<W���꾲��G{=슜=�߬=��> $9�0�v;�ݷ=^���>a�==d0:���$��,�s����؍�����N>�h���W���(׽���=!�߽Ǹ�=i]r��Z:=��ýM���۽R�,>���=�͈�ߦ	>뚸=\��<Z9	��M<��
=9�=��Ͻ�=��-=��k�(0>�͚��Dr�\��}��'�=\O>�+�<�`>Kv�<ҠX>�v~���>m>�Ib<�!�:x>�>�6p>p��G�~��}>��=$)����>q%���c��Q��q�<��휽h0���H�o�
=�f��˶��0;�$>x*��ET�tt7>��i=����������K�X|$>�u=!��=�齧^8���=���� =�i�=��=��k>)첽��P�����'���j>�
>E$���U�<D����z��9�Ӥ���8%��Ƚ�d���.<���<������;��h���߾�=��o;�ǘ��m^��o�����<eȯ�eG1>6�K=f�ͽ��=�z^�Ш�=��
�g�/����m�E=�z��[��=���/̋=u������>˕���Yn�����:����x-��p�=�ߢ=�?=��J<AsR��&f�v;½�/
���t=B>��ؼ\Vؽ����^9�z��=��<�{Y�=+o�=���=Ɠ�<3]���M� A�C������=�>Bb���ѽ��X���M>?��:W�����޽3b=p͂��5>6������E8�=X��=WR��Ʈ��]�=�B=-ʟ��۽R)c>>/K=�)>�۽bXV=-t��S
���@;O����־�pE��,��M�;V\Խ����CaY�v�ĽD�/>Ⱦ>�ߦ=���B�=f��=:j��I�>oإ=">v�K��-�=/\�<� >5�V<���e����<-�>�̽����=�_��#�|�r�>2���=Nq*=C�D>��%���/=�2��>�Em>���=�8�<�O���xT��_<#%=�,=�á=r>����,+>�ˤ���=t|O<p�Ƚ.�>K���a�\�
��<EX��ط�����",>����ԙ����=�S=W�Y&�=�8r>�Έ=�1�=�^�=�I&��#��6��=���<�c��_G� /�=��?�i��=��S=$!��F�=�.>��9>��ǽ���pܴ��*=���E��;���= -�8�?=����ὨHz>��&���S=J����M�0Y���%D�Tj�k���	�)>ӢF>`�+<�h��\�佇ߜ������s�I�=�8����=Ґ���d������>Kպ�y���dF��`>�H�=�r$>��<�iS��9��d���Pi=��N>�\��ە�Zm=Ë�����1I�>{�/=f�= _;��=�#�����=>n�����>!�n>�˃<��\�!������;4�D���<�s>���L|�<�2>^m����b>d��<2=&1}��<� �K�A>:o����ܾ`��,V`��;#�%9&>�C��;�S=�T�<���>�=�<��>7tf�L���m^>�1)=�
�>տ����=�6���\~<!����=�pI=\��HQ1>Y�=ff����=���<>�
�>�S=�!�=��=�p��ȃ���D�ۊ��n6���ü}��8���,�2�'����=�)�����O|�=z�O�_k�=>��E��=��F���<L|9� ƾ)�Q�*#3<�6��b]C=A�>n���&w�=r�#�|�m�/�K��8L:�\ٳ=�t>�N=vH;к#�^IU>������a�m���$�=G�������4�a7�=�D<n��=�y'����<xTG=��.=fҥ�zE��sH}=~ﹼ�8c�~�<�/����A��0��r�=uB����2*��=����/���A�<��>�Z�����Ԩ�O��U~@���O��N2�$�K�@^��=<���m=6ّ���=�3p=\vO�&J^��,\���c�k��=V۝���e;i �<��=��>�p�=<U�=���H��S=<0�'���>�� >�Vɻ�*>�Ǽ^
!<�V>�f9��5�=����[���8�=���=�:�|I$� *�=:O����=�
;��V>��=�B�
�k���9=_�Y>p�>x_��GH���]=4 .��LK�k�h>��~�?�7��B��Ö=�+ӽ�����h=����J+�<�
=�G<>bJ>�(6����=&	�!l=���</R�E>�Y�-}�=Zl��m>����T3�6'��yD;��A>��O����=���������z騼U`�=�sν�D޽�+�=�@��Ƚ\�ۀ!��)�_>f� >�K�<, ����=i�&���>�Tm=�D��Վ=��ʼ����h>�>�M�Y�:n��=�I߽�1�=�[��xq>'Dʽ&�A�4��dS�=���y�P=�������~X�=�Z|���2��e>f=�uC�=&;�x���ˈ>���=*K���d���=Q��=�=��O >jP�=���<y�z=��A= �9��:-&����D{+�h��=���<�4���镾%>ohe�>�y=��!;nWN=x���м��̽��~�b��( ���w!��Ǽ��l�+�<�
>���=3*��-!�B	�=�Ӈ�~L=����Io�=l'�I	^<	s��X>�J�Z,;=���a��=����tWo<��m=��Q�H�Lk�<3&��fL>QU��=w�=	 >�<,�뻛;}X�=cu��hȼE�&=0�;>������=��)>ǬK=�{]�ë�;�;�=�<�>�����:=)2j�G࿽^-8=or��ӛ���f���6��<�E>m�m������Z����S1=��i=0��w�5��`����;߶>���=�.�=���	���I>�8N>t�����S��G �<"+�=q��=��t�#���&4f����=����(2=T��<+Y�=�)佝t꽨�=H7�<��<��=�+�=S>s�����a�}{�ch��M�n��[>
�>@��j8�<h��6=0}=�{/'�b6�橽�m�=y8>�Ӣ=��>{�3>��۽*����3A=�����8>�D�=`�������1�/<�e�0#>��w<�2�=�iZ>���zz6���<=�x���p���4:�(4�=�bѽR7�=%��T\�=���=���{P ��-��#J��<�O��>2e�h�
��=���8�0>҆�=�-��vܼ-+>oG;D ����=���=��W�D��;]�!=���P�t�f��<�W�<��>~~�=C��ѿ>%B�=Ta<f΃��H～���ی=V����I�=�hQ=nZu����<Gĕ����;��(��e�6=:~��@>YEv=��U�9�a���<�N���=�œ=�I�=��v����1�ƼA;���6��{h<�I���	���,�i��.f>�x��A�=��'=f�w��=Ӯ^<)���d΍=v2���=Tz���1���Ӏ=��5>���=e��U���g��=_J�D�����@����=\&h>�h���U=<�?����<�S&=JZ����>�|>w�Ž�U^=�f8�͑>�f=����;=-�ۼa�M=97�<���=��R=)?����<�G>=����>�=2�����=�*�=G���;t��j��y�=�n����ǽ�?����jM�=󺗾o��]�w:���U��:_�:ٗ���=����4�)���|W=g��=JV�2�+��v��HY�=�3f��楾�L�B��<g��Ċ���V�ӑ��w#=9s)�V;����>�u�<�'D>��=n�<�ꁌ=�a&�vq�=�UT�u�=^��=Z�T�<ӊ���	=Ћ >X�f<�ے�H�8>����\@\�w਽��F�=6f����y=>Rм����%��:��=!}R���]Gj>�-=�W<�=�v��KD,����=���<��0��(=�x,�����\��'�o=f�[��1�<�6�=����):��k=��B�b���$<��1>J�>�5�=��H��=7>��>BY=:h	>�>>�)�f%,�����N�[=ӀB<��ЦW>ܚ��Mp)={a�;-P׽֗i;'F�=��ԍ��但��=�7P�H�V>�W���&���p;�F[���>)�8= ��mzx=�N��P������+��<�=Y�i=vF�Su(���">^��='�N�,E��,�t�&^=]>\��J���9�7�o=�L����AB<6���y��Te����ҽӼn����=ڵ!>�,��`Ͻ½e��c3>�>�=܉�?<{<'ۨ=��>ޭ����=���=��='6����S[>�g��&��~�=��	F>�Q�=B(:�`n�=��[�wcܼ��>��K���&gz>G=��q���)>;Z�=Y��wy>�s��H
>�]��Б=R��<��=�~�<��ӽ)��o�>'�异Ha������5��Z>F��f��=͊4��r2=og�=:YӼ�!=�wú��>�&M��ܽG=�h�<0�>7<=�ˤ=�^����=&A_<Cr��D>�=Bz�=���.J��]�&>�%.=���=�$y=Y��=�T)����;:W���D�<4���nY:=�a�='�������F��N$��q�����=1 >�1<�	���;���=���|c���<J�T�8�ʽ�U��z#>D��U,������e�Ug�;&���p׽w����Ll���(��W������!��������=���=��<��M=X�W��<O��:�22�=���{ ?>�a���I<c��=��=|��8h0����C���=Jzc���O���=6�=����[���/;�/�=�s�<���hZ6>�3��
?;>��W���z��֬���i>�/���C=��@=�G*=7�n�鮘�J�=�-��tl1���ϼ!Q�=�l�=�1R������;�|>(���=8 ��{����&���<��<O��=�A�l>�=�ǽ��=e[���Ӊ=��>��<���=�Om�������H��\�#��VӼ}Lo=��<O�=�+>��-��,Ҽ�:�p^�;u�ټ���Sq������=h</::��<�U]�o���|����=1N$=1��K�%]�>��=M{�mՂ<���2B>�����]`���.�+�,��s �	V�<��<;GȽ�`>c�)���<>%��4�񽵜I��C�<o���:>`�_<�"�?�r��8���([��>:=�J�<���;g���2Z�=��=���Sn�F^ � ]�������什��=���=�k<�=��f��0�/>_�=P%�8͍����9�h>�ֈ=M��=QQ��O�<AW����9�:=،���~;>��=�����FG==�k�Y�0��g!>�Z�=�Ƭ=��@=��v��r�=�<?�� x>�S�=z���EO<J�0>T�1�M��0H>�I�W�)=�9=���;�Ps��<YF����@=��{=��,��
�?���z���$�=[���=�)��_��Q�6�T�D�}-�<�ސ�E�n���J=�r�<�޶�?�)>�ͼK�=�1Ľ�a���-=d�K=�4�2I%��١<�X���$�����`��f)>�H��&�=�뤽�sT�g9 >�Y��޿�=�?�=b��=�Ӽmaҽ6Va�P�>G��,�=�.>�~�=       ��z?���?��?�Sv? ��?(��?�Iz?���?ֻn?��?��?���?,_?�FL?�^?��?�:�?e{u?Ch?F��?       �G      @       mΰ�K/�;��><C�#��P>A�>��b=>�~�=�'�=}��=�F�=څĽ�<8�M��=n��<%z�=Ĝ�=�:����=�˨���=��e=;I>��<+qZ=�>�%>�8#>>�L=Yg�=���=��@<�.<�)����=��<�H<3<(=���=? �=�j=��=B����;(t�gx�R���f�;;Do�V���&#<�4�=]<zt[�t��=�r�<HE�v�>�4�=-'�<9��=��<m��       �;� :ڽ%;�H:;��A;D�f:�pD:go;��6;��;g@�:���:��;6�;���:�f; $:���:�J<?�:       �G             \=�����e��񯅿e�%���Ծ�'9�]�
�0�7>����(9�p����/����>[>^?�6�>����Լ!�-��UE>       �G             $$���K4��a�<-�o���;<ċ�\��=�:V�J8���G�����7���;t�>sܮ=h�>=�]��������=�6�=       ���ۺ�{���b����'=4�9�R]=jn/�c��<�W<0>	�=��>��=���=����q%=2��<(w�=�B��      f����)퇽�P��`	����=>���'�'>��=ɘ���E��[0���m8��>��N��f��^����=L�1�Â�=�U	>�d�=`�=ٻ�=X���z1���1>ᤵ=Q����D<�iz�3��=���^>;Ck=���	��Q����:-��t��<�y<�3�=,�>��;�Jμ�����>�m=���B{���N>�ت�*�="@�Sܟ��T�=�]�=#>�X1(���Q>fS���Ǽ'��^�m�@��=`�S��I�=��=���=�j�=�B��,:@�^>�0>>`<؃����_��l����	����&�=�Ú<���<���D���	��4;P$����=/h�Jg+=V�=�d�=��S>�	���m��uY�k����n<�"��7!V>����F�8=�6��v��=
�>nt�;P�;>͕c�A�=���l�N��=u�8����=���F1�=𣽨m�=�}���T9=�kl��̽t$���~�=��^=� O��ņ= �4����z=#>T}���ð��G-���k;M�&c,;�?��(�G�U>->�Y��[���$8t=�yB�E)9=e���ɽX~n���&�=ݙY��C�{蟽���=�-G�~�>��=�#4����=;����[Y�=���=n�P�/a>��b=P.z�D�ۼ�y�(-���������=����IV>r����z(�S�=�����jټ|�$�Y�����}�<Ɏ>�5�\$�BK�����=f��-)2>싚=���L�=���=F���/a��忼�[=���=�>�a.=b��"s��g�y����{=���׭=�u>��]�c�M�O�k��P7;t�>�]�=��8��`�=�t=_�E>�I>]�j��,žN�:��X���v=S������=��b=���5T�?��=�e�=��3= ����2��\i\>�2=�ԉ�2�<��0>�;����=9�^�v1���ҼcB"�Ϋ�=�8d�,�o�Z�>��<��=,�'>�A=�㸽�n�=<�3��B��դ��=�/������tƽT$�����=>��=,�u�m�=c�&�sI�<�;%��k3���=P2���
�/L>��a c= )�ܻ�=���=}�<H>��5+�=9Y�=8�����p>��=?���<�¼�= ZK�]�2��S�=���;�\U����=�h�<s#���>>�B=xgh>��=�@�Q���>��=�
ӽ+�����2�F<mO�'/ͽQ�=m7�< ��/I���t�A9��&s��>��=���8i(���<�+�0���1�=u��>�<���{@5�,�Q�13>C�x<�� =����lL�=�E�<{�>L>�э=�#=�ܽ!q���Y=	�[>�E�Xi���JR�A�K=�����M��Đ<n/�=������0���F�=e�����$<��W>�>ǽ�[�(<==^��<OM=1�"�;=�=�k����=��A�$���2ܼ��>��Ƽ�<�->mC�<0c�=�p��d���Ne�i�R�+뽽">�w�ead�x��<��<g�>�-�%��=f���xv<=b�=_So���e>�k'�H꨽9R�}ýό@�|�D�Z�=0�!>��>F$3���<rw?=@�A�&M��8�h�=����7VL�"c�����J�����)�.�I[��ˊ=�.��Q�=�{=� I��F<��6��H�<�@>
E�=��/=��;S��<X���I��%�}Tq=��*�$���?C�9�-=�栽�F$���<I��2𜻗݅�Q�0���B=FN��k�<>ڃ�����>?9��=�Z�#h��C�=���=HbH>��+=��&;!">~������=�B�[�t���3�=-^�=�r�=�Ư=@縼���Cƽp��<VJ=���bK=E����L>r�>�ּ��+=�j#���=�l��7H>��"��t>��<U��<�+�=�Ϫ>���������=���X����;>�J��Ǉ�|ͪ�Nke�����!x���~��3IG�lڍ=}���t-�������2��=���=��p=��n�Q��	�ؽ��>�1O=7�>�(�.�M�N��a�ὸmM������'�>E�<h|���B�Q��=݊<ܽ��>x�g<���U��=����X���"��G\�=�yݽ�P�=�c> >���.��=k:�.��=����6_��=ս�\�<CQ����S�=&j���	x����=�o��4�M�m	���h���;=�cB�����[�=�����=�o�=R5�=q"�ŖûB�=��<�>��i��ʃ=�\
=��>��޽�,Ƚ�2f�5�'�~�Ἢ������=�rf=Z�3�P����>F��<��=�M��q�/>�����߽��/Ȇ��9=��b�o�9��1l=ճ<���w=�z��|>�'��G�l=!��r:�p�Z�0���I=e_'�n��=�rӽ�=��{>Buk=�%��<�{��<$s�<�%Y�8@����\�3>�^��J뻄m=ߩ����z���<:	=WE�=$��^�+=0B��貽�X�ٸ��(��������=:t�Kk����ʼ�_ͼ�}��(�������W��3�=����5}߽�m��P_�Bt>�pP;eJ�=A[�=����X���z�	�z	>I�׽�M�砞=-����;6�>�QG/�l� >��9=N��=C��<����:�S=p��nP�-%�����k���P�hcZ>�լ>�� >f+��B�w=�J���R �=t���{����U�O>N���`0ƻps->#�e�
>X!��r��=ܞ!���c�׫½���=�?��T�?�f��<b������=�Eg��ԫ=|�輚��;���>� =Z-�W�ٽ���;<�<�@�=�$i�=�=(=�Ἴt�j��j =uF>Ȁ�g��=RN >�3�>=�	=�j<J�=v1�=6ؽ�U��4���uI>�~&��~?<�+1>Q�G>�-�=�K<&h�!gO��5�%�����=�=�����VJ>Q��==�>E�e=/�=�jm>�.G=��8��Z���U�=��-=mS׽�Խ[R>%�<#���$�X=�x=H2
��a��5���|��*-;yTB�r𽙠B=[z*����=�!=>PN�=Z��<K�v=nQ>P�>�b�M-�������Fx�<���>��"����C<׮+����`.=�>�;AJ=G໽.+>MPԼ�����=$�b��}���׽��Y=����d��g;켸��������������L��=�f�=�2����=��
h�=uC뾒쨼sB�=�5޽�%�yV=���<7�|>F��YS=�{>.l=oq"<+����кG�=���=����? ��4H�j,3�#]����������<�E=�|!>d�$��&�=E�{=���=��`���M����fb>G�=�0=-��SQ������훉���p=+��<��=?�?��W�=Y�:>��=�g7����<�=(u��ڕ�UOǼ=�&��(��E��G!�-f�%�̽�8�p��>Va1��6|���a�7�>�<�=0'�=����u���1>��<�j���2[�=l�2>�����_= �=�O�=���>�,r�8_;���̽N\��F��������10���q��̙=N�G�vRE>|��<r�P�5��>����C�׻�I�=��`�%;E��-=W'����=�$�<�ǭ;�0X�v\U>�ഽ�m=� (�0��Tm�=�ižL=3��>d�~��ֽ��V��×>���=pi9=���>�H��-D꽕+潺�=TU:�ϻ(;z��:z=�ٽ&�+�������*;�Ӽ��R�wG�=Ft�3��Pg>"짼�o�:�">��=.q����:������ϥ��������=�2�~�}<��E�u]���%	�`i>���^;�e�X�2Qg<e�=b�|���9�ҽ6�w>^�g�Nv�=�GG�ҽA=2*�<�[!=S�
>�'�� 0>A~0����,s<X�=�)�>J��"��=��>	!��^�8�ҽnZ:��P�="{ｙ�Խ�E�=p%�=w&�Ye�<�=�����̽ ���=��Ƚ�L>��>{�e=�����v>B�N��M����{�*>+ڬ=2}==�E�+N�=�<�銽	;��J>�
1�sA<�y�2c(��6O���C>���<t6=��=:Ľ��r=Hے�DZ:=�̽����_����ؘ=m��<A�5��H[>Ȁ(=s��=~7B>�^�C9��v1�Ď��N@�>1!�	a)>�<>�@=�����;x<()����	=Li�<~?�<�L�rc>��=��(�'�x=�=�ֵ����+�.訾�32�T�=�5>���=�=����CĬ�ۮ#�x��n#��_>�t��=���d��CE���͵;d`i>��<�"�t<��^�=>��.l�_C�����=�d��U�;��\>��>���Ǟ�= 9<[��<�>�=� �>�>���?�\��Odt<T2�XL���v�d ½G�>|X�>�&Z=[�>}��=+��������2>��0>��Ϲv�v�	�M,�:�W���7� 4�N�_=��	��Z������|��$`�=nDN< �<=؏�&x&=<�^>�4�=j(~=�R>��s�=|�*��Ԣ<Ix��6���3��RX�<���=eE>M��
��=�y�<���=-�	�G���jy�9�ռ�ّ�I�ޞ[�8���E΂�]�\��0U=w5>�k�>&L�؎�j�>��Q<����WA�rǻ��`:��7�Z�>�l'>A��<�s
����<���
���v$�	X�;�X��x;���=�(�ۜ�9W�=ɔF��|��+��U;�F����C>unļ�|��s����P;䜞<�H�� ����0=�u^�Sv.�d�=�1�=�.6�:q=���=��)>Ye?>�O�<�
��s�l�a͜�p"�A�!�*{J=��D>( �=�yX=a�=�}_�M>�����D>��=n%�=���Ua*��5>�Hn=_p�=�+ͽ��;�S,�wG�J����I>�[�=��<��b>��E����<#�i��ſ���4>_0���4� [�=��Ƚ\ȏ=��G�=bP����=�>r7>�Rý��j��ڍ��}:= �����=]��< �<�&]��O�<����s�]�&>��0>O���3��R�JԴ�g�ɻf��<dF��]r>NH�<	y>7K����=�;㽜>U���|}�|�H�����,n��{>m�<���9����4�=f`>p=�x�i[w��ݽ��L�=zeJ=�=胀��yd>9Ӓ���>�����Jo�=?LH�����3�L��Y���x�WW">K��N񓾰O��&�>%����=B����t>1�>����S6=na2�Pý��|=��}�3I;���¼�Ϳ=A�(�K�=F�;��:<�HT��)὜k�߫=^;y�>;�=Sg�<7@���y">�����5���2����_K:�h�=��=�FӽP[�56q��
�N��=ɐ�n;>!�����==!^<OA|=����S?�Ó��Z�n<Ąa=�*Y;<���)���M�;H����hk=��8>��<�������<65I;��=}�=l%�<\V�)����>������<,]ܽ�5U<�����xJ��fռ�(5��N��7=��J�-~>����{<���=�=���=#��R�'����=L�-��U?<�����;Խ]�>��^>5��=?�=e�=�V�=�y3��N�c�i=�|�=�u7�0h�>�!���/�=�,����B>��=��a>�0���j���/>"�'��@=�V���<��=�m�=`)��u�>n����ڽ9p2>���ݠf>ɲ�=�5�9e���[����;A���,9����])�Mx�ƃ��2��*B>����L<@�P��A<�Nh=���:��⩾=z؅���`>���eJW>e>�$�n= q}�ش�=[��<�dڽe��i�E=ie�=C�<�v⽊$^>5UT���޼�Ò>?Tq/>�e>�%��Dx<�Zj�X�>˵�=B��<�q=�A?"�ҽ�=�I�bt�<Ψr<��E��?=NŠ=K���b-���޽c� >����$�6�ƽ���Ș*�W=~=�4m�MW��Gﻰ��=�yg<�'r=ws�=�� >Dѽ@�K�5��X����Y<��=+
ƽ�n�=���=932>x^L�}?>�#�=���<�������=T���]�(�n<��� �d&[=y%5<�"m=����8�������(�=0*�Dt���c=��|A=�{�aԡ��u~=��~<��$�|`(<�$�=�n�y)���&<�L�=��	�H�I=�ώ�Ysڽ�j>(� ���Ž�y�=鍽�B��#	>G�g=��8�����p]�<��n;k;>��(;���k�żA"��f���	�޼�����<ɩ�����A>��c="�>����g�齳��=��;\���@c�=�Xֽ���h�����=y8��<$�%��L����>�)>Ú½p�����Z�Hsg�띗�&j��W���*=�+>�)��z*�= ��~ȫ=�����-��^���⼩Hn<�Z ��4v����=;J�=7S>�uj��1���5�f��>���=�K9=�V=~[�N:�Ť+�:k�=X�r<ܭ �����l|p>��<Mg���=�F���6�$2�=e!X>���=�ל�	)�C
�=0��<���<Z|�=6���2�����<���=s[-�v
�=T����ʈ�+X�<�o���Ѽ2w>�/>*��t텽��B>��=��=݇[�FS=�����L>�_߽��-�=���=��9�Y$�=���R�>S�=ԥl=Ľ�V��s�u>�:0��1���=Tł=�0;b��<^�����=:�w=~�>q�l>���1/�H>4=x��Cr>�v4=�b=C�x<U&����L���-����<>��@�|>h��>�<g�{>%I�=�=��������Z��m1���=��=��>=��'>ح��0�;�`>�'�Bi
>ZRݽ��V;��$�k���S�=g�e>����l!�<���D�N�p��<?v=��B��ힼ]�y3Q><%D>K�*<�C[�櫃�.�ټ���>y%�����}<B#���⽆��<p��~��;�O^�֬>�q�;���=2n=�U</_�<|4r=�=e]
��ﹽK�����U���R�nU�<���̾�<�U)�4׮=�����	=X�=�������X���b���}��ؠa�cp�< '�� L��a�kf�=�A��ic&>��L>�Ѕ>��=e�q=C���dϼ+>��;GV�Y��<x��=`�6�����<�<<�&;�$>"�=���V�"���߼
��=3↾q�:>Mr>>E�����=q�[�#4+<K �=*@��T�&��δ=��;����7=����9��b�;�Խ��=� �=��;���>�9O�!�=���=�>&���=錻���?=w���$�=(=�{x>��>������Rn�=p� �ܝo�A%>2=�f���$r=���E�����=�I�=V>�<�"�<�Y`�<wN��<Š�<X�ɽ/�+=�0����/=�}��s�:حA��݂=x�=���ݙ5��xU>	½���<D	G=E*R=!�=�Pj=-1伸týO׽mH�<̇���É=��=g](>�2>���=5/z���=�]9=�F���R|��Ⱦ�=Ϣ�=��"��G��'������u����B��D��=���=ѻ�(�-��G���k��%j>��2���,�B9�.q;���>/[�=��<PE_��=)�޽�@I��G:>	�>Y�\��RF>'�g�R��>��4>/��u���U�H���=1�|�s����<������=��O>��=}�=��*��b�<�p<Z�$;��7;��<iƾ���= g�<����J+>��f>*鞽B$ ;���<Z����<>�y���D=����{�l����~�Ǽ2mŽ���~&���e=��e��E�;��;�/<#TW���=�����[����=�1<�x��<�J���M4=v$�>A�R<Ƌ��� �>�>��=�E��g�=xz=G�Z��;=y����>l%����f�]�P>k�w�s{����>�T�eݎ��;�='�e�� �qJ�E�=��ݼR���RW���^>��i��'�<�=�=K��=�A��2>��=��½R�������/V��u��/�=k=4���6|ｻ<$�[h�<ޤѽ���=+�����=⨳��va�g�o��}�={�/=��U�ܡܽ�EϼgD����F<�>�-~�)��=�Mb<p��;a��:���=S9�<yмD%�=q����$a�$l�=�=G1�<��ʽ*==�� �[-ͼ<`���B�<��3>Rr۽!z�=Lݲ=V9<7�i�9V�=�$d=3:���[�=ahν��==�rX<�����a�	hI�h�[��\�����=�=!��>�	==c�m��=$�	=9 =Q��'Y��bw��_ý�r�=Z������6�co%>��=v���K�W>7z;�n >�
J��m��A����|b��f����=���ő�=ZK;g�#>�O�E�H���=%��>�����n߽CyF����&����ʼ<X=Eć>��ν_�;�n�8��!�l &=31���=�9��1����=��F>�۠��^��n�>Q��9Խ2ʽ;Aw)>D�<�Y-�������|�pFG>@(�<��7<q�#>�n��������ep�=i�5=܊�?�N��?:>����خ=yt��.U��[K=X���4��D�=U�!�>yB>�=mjx<!�1M=�y`=��>�������=,��G눾zj���<�RH��&e<�!�＂)��ߛ>�+�O�X�2o>a��<I��H\>�.���.��-�Ԟ4����=�O*�L)��d���;������=�K��C5�\��=He$��ץ�$��/�]<$ӽ����y=�3�<F#>�s��=�5��9S~=��1�����:ǃ;d���:<m1�s�>�ɽeD]�i���	�+`ŽQ@��C���_T�>%ڈ=_�]�H��!�:�P��������Q�!Ϗ<4�:=s����u&=q���j�a�� �}x�=�	a>��l���<��>l��<y�9���>��'�7�,=C�>5��=���=�Wg=�;F=�ۗ="z/>����t��ܾ�5��Ry�	7�>�H�6�J<���>����k>��O�=��t,�>2��uͺ��8�=k��Hs�>7��>G��<�m>��\>׮=�P=�ҽ��R�=p=>��c����=0F
�*��=���=��=9J<�T���=��2>C�Y<H0��ƼL�:(潟5!>�����Qn���">�40�����y2��- G�������:�/�>�'��l��<P=�>�X > 4�=��'>���=<]>�����+�'=ڕ��ٖ�2K�d������=�����}ἠ�	��j�=�Z�>�<9�1�H=����X�B��5��NfP�s5���.P�.%y���ٽ��-�κfT�=�V=%X=*�WG�=�wX���=�S��F�=����+����=�#��
,�"yK�ږ��x�>�@��|E;>���=k�=���=۽�h�=�L�=<B�*�,>XÏ���<���ͽL<����,>�;�=��=�j�4=��0=�f�;�+�=�6�=�xP��ʵ��R�=&�	>)�>�5��# =̵8=H�-�5�C>>���KL�;�d��^�=�S�=~l=��y=���=�h�<��B>yQz�$��=A\=]���PoD�M�<�!�+�,>h��C��=]WG�8�N>ғػ^�����9>@X���>/O��'f�=;�>Mw��])���S]��e&=������:>��E��
)<�ˮ=���寿�^k>�`�=�9<Zh�<!y4���5�gӽa+�=
�<筗��j۽Ys����\�A!!��Ҽ98��mr�@�3>�n>� 1���>�?ۼL��>7�Խ�ZҽV�B>u\>���=��]���7�I?$�bL�~k��5>�� >}��=8�H>4�&;hC=�Z�:��ýmx ��tj=`�$>T>N󂽖���]��V.���=R��=R5>s��;��=~�>�;�=i#O��`f>�L���=�̼�'=<�	�=и<>���:(�"���>���<����E>���_�g���#�w����-��k|�=v<��xה>{S�=��!>�������<�<45
>����l��О=��� >)%����I�<>�#>7&=m�<�p��y�=U�o> �l>_��;�-�M�;p��<�o��dT=tԢ��Y���B>��>;y>�I�=	
��Q=��;���"��<B��=[�;%�e���>�+(2>�/[�OZ�=�墼�"�=�U�i�<	��y������?*@=o6=d�"�쭼��`����p�#��qM>2�S>�;�3ҽ� >2"�[��=��(>n����`>�U�=���<i��;u����=P��>ʆ��/�z=
;�==�8=�Ϭ=�>S�|>�����E�=���N�9������o����<�t�<��!�k�7�=�'�=�ʜ=>��<H5����=�������>29>�-$���}��c��4Ǽ�?Z��D�Ě�����>�=x�$=��N>���&�ڽ]0>��K>�>%d�=��U=����*7�������l=��<�ԝ=r͵�8���&k����E��1b�<�'�<��}����4?�=����<>��g�{�m>½���=�>���<�����҃����w�(=�d���a�=V!>Yrӽk�ʼ��'��8W�ɻ�<��=�f�=�����v�=��$��F�=.�=��q��Ͻom�<V.ƽK\��aoֽ�٩>oX��R4>�(�R׽)���,'�5����tO=o��=8����:��G���<7���MM>@Qڻ�Z^={�>
�>���>5g�>������Gm��Z��=R�I콘��=�>&
�>I������=vT=��H�{o�<G<?^ >�g�<�H�4�G=�u�=	50>L�/>]��=�!&=��+>�o�<�kx��c����u��m�;)���v�ڽ�#�<�d���UϽ2��=�=-=J�/>| �0�i<��*� !W��0�<�J�;���^�ZB�<�;B=r�=�f��]`���m�:Z8#�/Yٻ�c�=���<��y=^�3<#�~:a�6��d=�5	�n`��*򵽀�������;���xM�ۤ���N����"�p��=��=�{�����;�<ߕֽdkA��1��0�d=Q��S�=w���=�6�J=�z�2�@���=��>�j�<>�Xн䄽�^���%��8>�N�b=u��	>�'u�V|4�4ڟ���^=k+��2�=�yսt���~�>���H�[*ϼ���q����\>��h=�i>/���j�=�^+=����m�[�h;[�		��0�r>c`�=�=��R=(���q�½b[U=E ��"0�*��&ƽ�(l>L�ϽΜJ=�#=�]��<.Ԃ�SM >>�m��j|��:�=�&���R��ۼ�<+:�=��/��3I>Gg.��ƼT����D�<���<^ɐ<�e��E=��w��n��}l=8��� ��Wќ="�F=��q>YM����+��.�;�н=���R���c�ѽ�s>�yV�m� >E>�j��bQ��80��x�����<'�=��(<<<�o�=%*?JŢ=x�
��������2�J��(λ<�Y>��*=����ڲ=7����!O��(�<��E<�l���"��&>���=�a��h<"=��=B,>PJ��|w_��A=nB�;��>���J�<��R��ߟ<�1�=�k�=�=;��;x<h'��
_��D�̼�Tǽ���=1p���j>��ó���6c>R�ѽPWE���S��<�𣼑R�=�T��>������<T=���L
=xJ����<-�X���(�}i��^1�;��D>F2X>M��Q��<��H>��V>�k�<�	սě�=�x>��=n�D�%oY:��>��&>7�)=t�< 	�=���\��=O�=��\���5�����=��<�'�;|2��I�/>V�N>�Q����<7`5������-;lo�= �0>ᦼ��j~�>N�3,�=�{=�T�:V�I�V=��<�.�Pa�<w���9���I*_<�V)��}��Q�<�w���y^>��������h>,�=D8>�5Ȼ���=c]P���]�d�	�3�%�f;6�gQѼUtR���~��^<\]B�߰=?k>,�<����|���y�=囶=p*i=�{=mq
=����I�T>	:@<)�6�,N�=HT�=�e	>#c���4=rK/==e�=sx�=���p��>�, �	彸�>�H?kT�=�|!>�<�ir=�Ǡ�y/�l;ͼ���P���i6?&�b�������M�=���=��w>��=F�u�<�孽��ƽ�-	<> w=�<=FiM��숾�l���)<�ǫ��0�XO�=�9e=�p���N|��>>���=�Hٽ_���%>,�� I�<q|N>�.=����=��(= B�=#s�=�;=��"�v=����½+�s=��.������t[�q���j?<�R�m{��f!�uJ�Go��<�Bb���g�W�I=P��=G��㪣=Y���<{q�c����-=�0> 6��>�V�=��d<�C���>#��U=Bnd� �(�̽5�=�Lp�I�ټ]P=[�>~��s�����l=�f�=`}>Kʽ��ƽ�)ʽ��k�t��!dV��Ҥ<F�<���"a��4f��##���=?���9�=�3Y�� =dW<�X6:w>)o���>����wd�C�=�j|�������<f$��P�=N�=eo=2g�=�&>Eu%=H�Z���<*��5N>�+/<<��Nl�=�X����<w�����=�#>����4��>R�Y>�����wܻ��Z=��)�1�ֽ���=0�ٽ���*F�=k��pX	�RmE>��<����5���=jJ�B�~�$�켁ݿ�X��֢<���T�B�A��I>wC�=��!�)~�=��>sII��I��w�s�D`I>�j,=(K$>�T�=3�9=(A�=��==cY�,��~�'� >�-�G7:��|8�,�M<	W��+����s<�2.>y@L={��n�f<_H�=A�����=Wz2��Q>�">�h��������=����j�2>�3*=�0m��bn>����=�{6� ��n;;�`���H=Α=����|�=���=�fνB�;�z>����A��<���=��t�cs����=(�n��J�X�=�y>|�<�=��7�J���8�o`V��JѽR�P<I�Y��@j��t���C<����Q�@�-�(J�s4����h>c�=krt=�����=rT>K:��;F|=NO=�O��i�v�k�S�=�x�Fap���s=�ac������x��	9��F�E��<��^>��>�>F���T>���=Q�;>޸�:�ֹ=-�=�Q���=��A��+�=�㦻*{>P.>N�j�����B}۽A��Hju=�uŽV�=[UW�h�½�����@;�νW��f�C�=��ٽO+����|>W�/;�*�=,�>B\=I���%�<`��=�=�0=�N�=��0��>D�=Z=~���c��g��H>	#�ٟ�<"����<�ռ�����Ӏ=��>��&).>��a>K���X=U��_^:�Ǧ�=Ԝ��MtE=r>�=�38�D�Լ%iȽ�T��'P�ގ�=/}�=) �H�=<�v=?xk��<�#�o���C=��I={3�=+��;H���D<����d)�4N�<��b<N;�����c���������=�
=:-8>�@R���>_>���y��<E�E�)�;C�<B�*>�D�=A��:'��=�"���(��b���r1>z��=^"�y#.>�͖=�M!='�i=��/�⧉=Dھ�M]��?=���|>8(��Q|<��r��R��=5�A��T�=�G>e��>5n�����ET�<�v�:@�D=��4����$F�< R->~����R<Z>���6?�;	�s=��ý�5=��=�s��*uF�W�/��7ǽ��;�O*����������1�\ ����=T�"��;ɽ�^[>�)�>:B�`��=       +�>��>��>ǆb=L��=�,D>�(�=�>�=�e=� �:��j>��/=��>���=�]A>�HD=���<*u=�,>3j�=